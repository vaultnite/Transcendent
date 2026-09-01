import Hummingbird

struct ErrorResponse: HTTPResponseError {
    var status: HTTPResponse.Status
    var payload: ErrorResponsePayload

    func response(from request: Request, context: some RequestContext) throws -> Response {
        var response = try context.responseEncoder.encode(self.payload, from: request, context: context)
        response.status = self.status
        return response
    }
}

struct ErrorResponsePayload: ResponseCodable, Error {
    var errorCode: String
    var errorMessage: String
    var messageVars: Array<String>?
    var numericErrorCode: Int32
    var originatingService: String?
    var intent: String?
    var errorDescription: String
    var error: String?

    init(errorCode: String, errorMessage: String, numericErrorCode: Int32, errorDescription: String? = nil) {
        self.errorCode = errorCode
        self.errorMessage = errorMessage
        self.numericErrorCode = numericErrorCode
        self.errorDescription = errorDescription ?? errorMessage
    }
}
