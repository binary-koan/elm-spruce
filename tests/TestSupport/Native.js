// const _binary_koan$elm_spruce$Native_TestSupport = function() {
//     const mock = require("mock-require");

//     function getEncodedResponse(testRequest, onRequest) {
//         let nativeResponse;

//         let testResponse = {
//             writeHead(statusCode, headers) {
//                 testResponse.statusCode = statusCode
//                 testResponse.headers = headers
//             },
//             write(body) {
//                 testResponse.body = testResponse.body || ""
//                 testResponse.body += body
//             },
//             addTrailers(trailers) {
//                 testResponse.trailers = trailers
//             },
//             end() {
//                 nativeResponse = testResponse
//             }
//         }

//         mock("http", {
//             createServer(callback) {
//                 callback(testRequest, testResponse)
//             }
//         })

//         _binary_koan$elm_spruce$Native_Spruce.listen("localhost:4001", {
//             onRequest: onRequest
//         })

//         // Hacky workaround until elm-test supports tasks
//         while (!nativeResponse) ;

//         mock.stop("http")

//         return nativeResponse
//     }

//     return {
//         getEncodedResponse: F2(getEncodedResponse)
//     }
// }()
