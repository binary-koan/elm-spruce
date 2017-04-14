const _binary_koan$elm_spruce$Native_Spruce = function() {
    const http = require("http")

    function explode(message) {
        //TODO handle subs properly
        throw message
    }

    function listen(address, settings) {
        return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
            const server = http.createServer((request, response) => {
                console.log(settings.onRequest(request.url))

                _elm_lang$core$Native_Scheduler.rawSpawn(settings.onRequest(request.url))
            })

            const [hostname, port] = address.split(":")

            server.listen(port, () => {
                console.log(`Listening on port ${port}`)
                callback(_elm_lang$core$Native_Scheduler.succeed(null))
            })
        });
    }

    return {
        explode: explode,
        listen: F2(listen)
    }
}()
