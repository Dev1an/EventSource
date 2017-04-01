//
//  main.swift
//  url
//
//  Created by Damiaan on 1/04/17.
//
//

import cURL

let firebase = "https://homecontrol-f0066.firebaseio.com/Home/0/Radio/0/currentChannel.json"

EventStream(from: firebase) {
	print("event:", $0)
	print("data:",  $1)
}
