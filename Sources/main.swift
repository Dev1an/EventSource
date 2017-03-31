import Foundation

let firebase = "https://homecontrol-f0066.firebaseio.com/Homes/0/Radios/0/currentChannel.json"

class Delegate: NSObject, URLSessionDataDelegate {
	func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
		completionHandler(.allow)
	}
	
	func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
		print(String(data: data, encoding: .utf8)!)
	}
}

let delegate = Delegate()
let configuration = URLSessionConfiguration.default
configuration.httpAdditionalHeaders = ["Accept": "text/event-stream"]
let receiveNotifications = URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
let handleNotication = receiveNotifications.dataTask(with: URL(string: firebase)!)

handleNotication.resume()

import Dispatch
dispatchMain()
