const { compile } = require("node-elm-compiler")
const resolveExample = require('./resolve')
const allExamples = require("glob").sync(resolveExample("*") + ".elm").map(resolveExample)

function compileExample(example) {
  return new Promise((resolve, _) => {
    const options = { output: example + ".js" }
    compile([example + ".elm"], options).on('close', resolve)
  })
}

function compileExamples(examples) {
  console.log(`Compiling ${examples.length} example(s) ...`)
  return Promise.all(examples.map(compileExample)).then(exitCodes => {
    const errorCount = exitCodes.filter(code => code !== 0).length
    console.log(`Done, ${errorCount} error(s).`)
    return errorCount
  })
}

if (require.main === module) {
  let examples = process.argv[2] ? [resolveExample(process.argv[2])] : allExamples
  compileExamples(examples)
} else {
  module.exports = compileExamples
}
