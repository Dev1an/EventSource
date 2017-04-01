import Foundation
import PerfectCURL
import cURL

struct Break: Error {}
enum Section { case field, value, comment }

public class EventStream {
	
	public typealias Delegate = (String, String) -> Void
	let delegate: Delegate
	
	let queue = DispatchQueue(label: "HTTP EventSource")
	
	var fieldName = ""
	var event = ""
	var data = ""
	var comment = ""
	
	var section = Section.field
	
	public init(from source: String, delegate: @escaping Delegate) {
		self.delegate = delegate
		let curlObject = CURL(url: source)
		curlObject.setOption(CURLOPT_HTTPHEADER, s: "Accept: text/event-stream")
		curlObject.setOption(CURLOPT_FOLLOWLOCATION, int: 1)
		
		queue.async {
			while true {
				let fragment = curlObject.perform()
				if let bodyFragment = fragment.3 {
					self.parse(String(bytes: bodyFragment, encoding: .utf8)!)
				}
				if fragment.0 == false { break }
			}
		}
	}
	
	private func parse(_ fragment: String) {
		var unparsedBuffer = fragment
		while !unparsedBuffer.isEmpty {
			switch section {
			case .field:
				if fieldName.isEmpty {
					guard !unparsedBuffer.hasPrefix(":") else {
						unparsedBuffer.remove(at: unparsedBuffer.startIndex)
						section = .comment
						continue
					}
					if unparsedBuffer.startsWithNewline {
						DispatchQueue.main.sync {
							delegate(event, data)
						}
						fieldName = ""
						event = ""
						data = ""
						unparsedBuffer.remove(at: unparsedBuffer.startIndex)
					}
				}
				forEachCharacter(in: unparsedBuffer) { character, index, nextIndex in
					if character == ":" {
						fieldName += unparsedBuffer.substring(to: index)
						
						if nextIndex != unparsedBuffer.endIndex && unparsedBuffer.characters[nextIndex] == " " {
							unparsedBuffer.remove(to: unparsedBuffer.index(after: nextIndex))
						} else {
							unparsedBuffer.remove(to: nextIndex)
						}
						
						section = .value
						
						throw Break()
					} else if character == "\n" {
						fieldName += unparsedBuffer.substring(to: index)
						if fieldName == "data" {
							data += "\n"
						}
						fieldName = ""
						unparsedBuffer.remove(to: nextIndex)

						throw Break()
					}
				}
			case .value:
				let newValue: String
				if let newLineRange = unparsedBuffer.range(of: "\n") {
					newValue = unparsedBuffer.substring(to: newLineRange.lowerBound)
					unparsedBuffer.remove(to: newLineRange.upperBound)

					section = .field
				} else {
					newValue = unparsedBuffer
					unparsedBuffer.removeAll()
				}
				
				switch fieldName {
				case "event":
					event += newValue
				case "data":
					data += newValue
				default:
					break
				}
				fieldName = ""

			case .comment:
				if let newLineRange = unparsedBuffer.range(of: "\n") {
					comment += unparsedBuffer.substring(to: newLineRange.lowerBound)
					// TODO: emit comment
					comment = ""
					unparsedBuffer.remove(to: newLineRange.upperBound)
					
					section = .field
				} else {
					comment += unparsedBuffer
					break
					// breaks out of the parsing loop because the whole buffer is parsed now
				}
			}
		}
	}
}

func forEachCharacter(in string: String, call delegate: (Character, String.CharacterView.Index, String.CharacterView.Index) throws -> Void ) {
	var cursor = string.startIndex
	while cursor != string.endIndex {
		let nextCursor = string.index(after: cursor)
		do {
			try delegate(string.characters[cursor], cursor, nextCursor)
		} catch {
			break
		}
		cursor = nextCursor
	}
}

extension String {
	var startsWithNewline: Bool { return characters.first == "\n" }
	
	/// Removes the first characters up to but not including the given index.
	///
	/// Calling this method invalidates any existing indices for use with this
	/// string.
	///
	/// - Parameter end: The index of the first character that should not be removed. end must be a valid index of the collection.
	mutating func remove(to end: Index) {
		removeSubrange(startIndex..<end)
	}
}
