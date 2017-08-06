const ava = require("ava")
const exec = require("child_process").exec

ava.test("Headers are set correctly", async t => {
    t.plan(1)

    const Elm = await loadFixture("SetContentTypeHeaderToJson")

    console.log(Elm)
    const server = Elm.Main.testServer()
    console.log(server)
    // const response = await request(server).get("/")

    // t.is(response.headers["Content-Type"], "json")
})

function loadFixture(name) {
    const elmFilename = `${__dirname}/Fixtures/${name}.elm`
    const jsFilename = `${__dirname}/Fixtures/${name}.js`
    const command = `elm-make ${elmFilename} --output ${jsFilename}`

    return new Promise((resolve, reject) => {
        exec(command, { timeout: 5000 }, (err, stdout, stderr) => {
            if (!err) {
                resolve(require(jsFilename))
            } else {
                reject(err)
            }
        })
    })
}
