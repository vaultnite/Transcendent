import Hummingbird

struct ErrorTransformer<Context: RequestContext>: RouterMiddleware {
    func handle(
        _ request: Request, context: Context, next: (Request, Context) async throws -> Response
    ) async throws -> Response {
        do {
            return try await next(request, context)
        } catch let error as ErrorResponse {
            return try error.response(from: request, context: context)
        } catch let error as ErrorResponsePayload {
            let epicError = ErrorResponse(status: .badRequest, payload: error)
            return try epicError.response(from: request, context: context)
        }catch let error as DecodingError {
            print(error)
            return try await next(request, context)
        } catch let error as HTTPResponseError {
            let payload = ErrorResponsePayload(
                errorCode: "errors.com.epicgames.common.unknown_error",
                errorMessage: error.localizedDescription,
                numericErrorCode: -1
            )
            let epicError = ErrorResponse(status: error.status, payload: payload)
            return try epicError.response(from: request, context: context)
        } catch {
            let payload = ErrorResponsePayload(
                errorCode: "errors.com.epicgames.common.internal_server_error",
                errorMessage: error.localizedDescription,
                numericErrorCode: -1
            )
            let epicError = ErrorResponse(status: .internalServerError, payload: payload)
            return try epicError.response(from: request, context: context)
        }
    }
}
