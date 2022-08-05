import * as fs from 'node:fs'

function testingDemo (): void {
  const inputData = fs.readFileSync('tests/data/utf8demo.txt', {
    encoding: 'utf-8'
  })
  const codePointsHex = Array.from(inputData, (v) => {
    const codePoint = v.codePointAt(0)
    if (typeof codePoint === 'number') {
      return codePoint.toString(16).padStart(6, '0')
    } else {
      throw new Error()
    }
  })
  const outputData = fs.readFileSync('build/iverilog/test_demo_out.txt', {
    encoding: 'utf-8'
  })
  if (outputData.includes('!ERROR!')) {
    throw new Error()
  }
  const outputDataArray = outputData.split(',')
  if (JSON.stringify(codePointsHex) === JSON.stringify(outputDataArray)) {
    console.log('test-demo: success')
  } else {
    console.log('test-demo: failure')
  }
}

export { testingDemo }
