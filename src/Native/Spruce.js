const _binary_koan$elm_spruce$Native_Spruce = function() {
    const { nativeBinding, rawSpawn, andThen, succeed } = _elm_lang$core$Native_Scheduler

    const http = require("http")
    const parseUrl = require("url").parse

    function buildServer(settings) {
        function encodeRequest(request, callback) {
            const { url, method, httpVersion, headers, trailers } = request
            const parsedUrl = parseUrl(url, true)

            let body = ""
            request.on("data", buf => body += buf.toString())
            request.on("end", () => {
                callback(JSON.stringify({ url: parsedUrl, method, httpVersion, headers, trailers, body }))
            })
            //TODO do we care about error/abort events? Or is not handling the request the right thing to do?
        }

        function handleResponse(response, encodedResponse) {
            const value = JSON.parse(encodedResponse)

            response.writeHead(value.statusCode, value.headers)
            response.write(value.body)
            response.addTrailers(value.trailers)
            response.end()
            return succeed(null)
        }

        return http.createServer((request, response) => {
            encodeRequest(request, encoded => {
                rawSpawn(A2(
                    andThen,
                    handleResponse.bind(null, response),
                    settings.onRequest(encoded)
                ))
            })
        })
    }

    function createServer(settings) {
        return nativeBinding(callback => {
            callback(succeed(buildServer(settings)))
        })
    }

    function listen(address, settings) {
        return nativeBinding(function(callback) {
            const server = buildServer(settings)
            const [hostname, port] = address.split(":")

            server.listen(port, () => {
                console.log(`Listening on port ${port}`)
                callback(succeed(null))
            })
        })
    }

    return {
        listen: F2(listen),
        createServer: createServer
    }
}()
