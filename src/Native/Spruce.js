const _binary_koan$elm_spruce$Native_Spruce = function() {
    const { nativeBinding, rawSpawn, andThen, succeed } = _elm_lang$core$Native_Scheduler

    const http = require("http")

    function listen(address, settings) {
        function encodeRequest(request, callback) {
            const { url, method, httpVersion, headers, trailers } = request
            const body = "" //TODO body parsing
            callback(JSON.stringify({ url, method, httpVersion, headers, trailers, body }))
        }

        function handleResponse(response, encodedResponse) {
            const value = JSON.parse(encodedResponse)

            response.end(value.body)
            return succeed(null)
        }

        return nativeBinding(function(callback) {
            const server = http.createServer((request, response) => {
                encodeRequest(request, encoded => {
                    rawSpawn(A2(
                        andThen,
                        handleResponse.bind(null, response),
                        settings.onRequest(encoded)
                    ))
                })
            })

            const [hostname, port] = address.split(":")

            server.listen(port, () => {
                console.log(`Listening on port ${port}`)
                callback(succeed(null))
            })
        })
    }

    return {
        listen: F2(listen)
    }
}()
