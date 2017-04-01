// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "EventStream",
    dependencies: [
		.Package(
			url: "https://github.com/PerfectlySoft/Perfect-Curl.git",
			majorVersion: 2, minor: 0
		)
	]
)
