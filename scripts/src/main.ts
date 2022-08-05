import * as fs from 'node:fs'
import * as cp from 'node:child_process'
import * as util from 'node:util'
import * as proc from 'node:process'
import { testingDemo } from './tests.js'

function prebuild (): void {
  if (!fs.existsSync('build/iverilog')) {
    fs.mkdirSync('build/iverilog')
  }
}

function build (inputPath: string): void {
  const setupFlags = [
    '-gspecify',
    '-gstrict-ca-eval',
    '-gstrict-expr-width',
    '-gno-shared-loop-index',
    '-Wall'
  ].join(' ')
  const outputPath = '-o' + '../build/iverilog/out.vvp'
  cp.execSync(`iverilog ${setupFlags} ${outputPath} ${inputPath}`, {
    cwd: 'src'
  })
}

function simulate (): void {
  cp.execSync("sh -i -c 'vvp build/iverilog/out.vvp'", {
    stdio: 'inherit'
  })
}

function checkExampleDecodeHelloworld (): void {
  const textEncoder = new util.TextEncoder()
  const str = 'Hello, Мир \u{1F44B}'
  const bytes = textEncoder.encode(str)
  const bytesHex: string[] = []
  for (const byte of bytes) {
    bytesHex.push(byte.toString(16).toUpperCase())
  }
  const codePointsHex = Array.from(str, (v) => {
    const codePoint = v.codePointAt(0)
    if (typeof codePoint === 'number') {
      return codePoint.toString(16).padStart(6, '0')
    } else {
      throw new Error()
    }
  })
  console.log(`String:\n"${str}"`)
  console.log('\nUTF-8 bytes by Node:\n' + bytesHex.join())
  console.log('\nUnicode code points by Node:\n' + codePointsHex.join())
}

function main (): void {
  const command = proc.argv[2]
  if (command === 'example-decode_helloworld') {
    prebuild()
    build('../examples/decode_helloworld.v')
    checkExampleDecodeHelloworld()
    simulate()
  } else if (command === 'test-demo') {
    prebuild()
    build('../tests/demo.v')
    simulate()
    testingDemo()
  } else {
    throw new Error()
  }
}

main()
