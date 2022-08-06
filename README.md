# UTF8Decoder-Verilog

A UTF-8 hardware decoder written in the [Verilog](https://en.wikipedia.org/wiki/Verilog). The implementation relies on the [WHATWG: Encoding - "UTF-8 decoder"](https://encoding.spec.whatwg.org/#utf-8-decoder) specification. For synthesis and simulation, [Icarus Verilog](https://github.com/steveicarus/iverilog) is used.

## Installation

### Requirements

* OS: Linux
* Package: nodejs
* Package: iverilog

### Steps

1. clone the repository
2. go to clone root directory
3. execute command "npm install"
4. execute command "npm run tsc"

## Usage

An example of usage is available in the "examples" directory. Its results can be seen by running the command "npm run example-decode_helloworld".

## Roadmap

* combinational circuit implementation (experimental)
* more detailed statuses (including different types of errors)
* elimination of the problem with three final "ticks" (can be solved with the introduction of additional informational signals)
* passing stress test "utf8test.txt"

## Contributing

To run the test, run "npm run test-demo".

## License

[SPDX: MIT No Attribution](https://spdx.org/licenses/MIT-0.html)

---

[Make a README](https://www.makeareadme.com/)
