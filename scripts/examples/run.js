const compileExamples = require('./build')
const resolveExample = require('./resolve')

if (process.argv.length < 3) {
  console.log("You must specify an example to run!")
  process.exit(1)
}

const example = resolveExample(process.argv[2])

compileExamples([example]).then(errorCount => {
  if (errorCount === 0) {
    const Elm = require(example + ".js")
    Elm.Main.worker()
  } else {
    console.log("Example failed to compile; not running.")
  }
}).catch(e => {
  console.log(e)
})
