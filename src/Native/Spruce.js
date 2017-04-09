const _binary_koan$elm_spruce$Native_Spruce = function() {
    const http = require("http")

    function explode(message) {
        //TODO handle subs properly
        throw message
    }

    function listen(address, program) {
        return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
            const server = http

            try
            {
                var socket = new WebSocket(url);
                socket.elm_web_socket = true;
            }
            catch(err)
            {
                return callback(_elm_lang$core$Native_Scheduler.fail({
                    ctor: err.name === 'SecurityError' ? 'BadSecurity' : 'BadArgs',
                    _0: err.message
                }));
            }

            socket.addEventListener("open", function(event) {
                callback(_elm_lang$core$Native_Scheduler.succeed(socket));
            });

            socket.addEventListener("message", function(event) {
                _elm_lang$core$Native_Scheduler.rawSpawn(A2(settings.onMessage, socket, event.data));
            });

            socket.addEventListener("close", function(event) {
                _elm_lang$core$Native_Scheduler.rawSpawn(settings.onClose({
                    code: event.code,
                    reason: event.reason,
                    wasClean: event.wasClean
                }));
            });

            return program;
        });
    }

    return {
        explode: explode,
        listen: F2(listen)
    }
}()
