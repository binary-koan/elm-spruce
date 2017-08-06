const { resolve } = require("path")

const examplesDir = resolve(__dirname, "../../examples")

module.exports = function resolveExample(example) {
  return resolve(examplesDir, example.replace(/\.elm$/, ""))
}
