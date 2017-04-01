## Installation

on **Linux** some packages need to be installed first:

```
sudo apt-get install libssl-dev uuid-dev libcurl4-openssl-dev
```

## Missing features

- Newline separators: the library currently only works with `\n` as newline. The following separaters are not supported:
  - `\r\n`
  - `\r`