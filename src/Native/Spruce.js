const _binary_koan$elm_spruce$Native_Spruce = function() {
    const { nativeBinding, rawSpawn, andThen, succeed } = _elm_lang$core$Native_Scheduler

    const http = require("http")

    function explode(message) {
        //TODO handle subs properly
        throw message
    }

    function listen(address, settings) {
        function handleResponse(response, elmResponse) {
            response.end(elmResponse.body)
            return succeed(null)
        }

        return nativeBinding(function(callback) {
            const server = http.createServer((request, response) => {
                rawSpawn(A2(
                    andThen,
                    handleResponse.bind(null, response),
                    settings.onRequest(request.url)
                ))
            })

            const [hostname, port] = address.split(":")

            server.listen(port, () => {
                console.log(`Listening on port ${port}`)
                callback(succeed(null))
            })
        })
    }

    return {
        explode: explode,
        listen: F2(listen)
    }
}()
