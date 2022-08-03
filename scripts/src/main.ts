import * as fs from 'node:fs'
import * as cp from 'node:child_process'
import * as util from 'node:util'

function prebuild (): void {
  if (!fs.existsSync('build/iverilog')) {
    fs.mkdirSync('build/iverilog')
  }
}

function buildExampleDecodeHelloworld (): void {
  const setupFlags = [
    '-gspecify',
    '-gstrict-ca-eval',
    '-gstrict-expr-width',
    '-gno-shared-loop-index',
    '-Wall'
  ].join(' ')
  const outputPath = '-o' + '../build/iverilog/out.vvp'
  const inputPath = '../examples/decode_helloworld.v'
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
  prebuild()
  buildExampleDecodeHelloworld()
  checkExampleDecodeHelloworld()
  simulate()
}

main()
