## Installation

on **Linux** some packages need to be installed first:

```
sudo apt-get install libssl-dev uuid-dev libcurl4-openssl-dev
```

## Usage

```swift
let firebase = "https://homecontrol-f0066.firebaseio.com/Home/0/Radio/0/currentChannel.json"

EventStream(from: firebase) {
	print("event:", $0)
	print("data:",  $1)
}
```

## Missing features

- Newline separators: the library currently only works with `\n` as newline. The following separaters are not supported:
  - `\r\n`
  - `\r`