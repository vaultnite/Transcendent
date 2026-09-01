import Foundation
import Hummingbird

struct AccountController {
    func addRoutes(to group: RouterGroup<URLEncodedRequestContext>) {
        group
            .post(
                "oauth/token",
                use: { request, context -> EditedResponse<TokenResponse> in
                    let authorization = request.headers[.authorization]
                    let authorizationComponents = authorization!.components(separatedBy: " ")
                    let basicToken = authorizationComponents[1]
                    let basicCredentials = String(
                        data: Data(base64Encoded: basicToken)!, encoding: .utf8)
                    let clientId = basicCredentials!.components(separatedBy: ":").first

                    let tokenRequest = try await request.decode(
                        as: TokenRequest.self, context: context)

                    print(tokenRequest.grantType, tokenRequest.tokenType!)

                    return .init(
                        response: TokenResponse(
                            grantType: tokenRequest.grantType, tokenType: tokenRequest.tokenType,
                            accessToken: "vaultnite", clientId: clientId!))
                }
            )
            .get(
                "oauth/verify",
                use: { request, context -> String in
                    return "hey dont do that!"
                }
            )
            .put(
                "oauth/verify",
                use: { request, context -> String in
                    return "hey dont do that!"
                }
            )
            .delete(
                "oauth/sessions/kill/:accessToken",
                use: { request, context -> String in
                    return "hey dont do that!"
                }
            )
            .get(
                "public/account",
                use: { request, context -> String in
                    return "hey dont do that!"
                }
            )
            .get(
                "public/account/:accountId",
                use: { request, context -> String in
                    return "hey dont do that!"
                }
            )
            .get(
                "public/account/:accountId/externalAuths",
                use: { request, context -> String in
                    return "hey dont do that!"
                }
            )
            .get(
                "public/account/displayName/:displayName",
                use: { request, context -> String in
                    return "hey dont do that!"
                }
            )
            .get(
                "public/account/email/:email",
                use: { request, context -> String in
                    return "hey dont do that!"
                }
            )
    }
}
