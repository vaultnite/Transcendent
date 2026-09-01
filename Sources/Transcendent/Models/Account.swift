import Foundation
import Hummingbird

struct TokenRequest: Decodable {
    let grantType: String
    let tokenType: String?
    let payload: Payload

    enum Payload: Decodable {
        case authorizationCode(AuthorizationCodePayload)
        case clientCredentials(ClientCredentialsPayload)
        // case continuationToken(ContinuationTokenPayload)
        case deviceAuth(DeviceAuthPayload)
        case deviceCode(DeviceCodePayload)
        case exchangeCode(ExchangeCodePayload)
        case externalAuth(ExternalAuthPayload)
        case otp(OtpPayload)
        case password(PasswordPayload)
        case refreshToken(RefreshTokenPayload)
        case tokenToToken(TokenToTokenPayload)
    }

    struct AuthorizationCodePayload: Decodable {
        let code: String
        let codeVerifier: String?
    }

    struct ClientCredentialsPayload: Decodable {}

    // struct ContinuationTokenPayload: Decodable {
    //     let continuationToken: String
    // }

    struct DeviceAuthPayload: Decodable {
        let accountId: String
        let deviceId: String
        let secret: String
    }

    struct DeviceCodePayload: Decodable {
        let deviceCode: String
    }

    struct ExchangeCodePayload: Decodable {
        let exchangeCode: String
        let codeVerifier: String?
    }

    struct ExternalAuthPayload: Decodable {
        let externalAuthType: String
        let externalAuthToken: String
    }

    struct OtpPayload: Decodable {
        let otp: String
        let challenge: String
    }

    struct PasswordPayload: Decodable {
        let username: String
        let password: String
    }

    struct RefreshTokenPayload: Decodable {
        let RefreshToken: String
    }

    struct TokenToTokenPayload: Decodable {
        let accessToken: String
    }

    private enum CodingKeys: String, CodingKey {
        case grantType = "grant_type"
        case tokenType = "token_type"

        case code
        case code_verifier  // for both authorization_code and exchange_code

        // case continuation_token

        case account_id
        case device_id
        case secret

        case device_code

        case exchange_code

        case external_auth_type
        case external_auth_token

        case otp
        case challenge

        case username
        case password

        case refresh_token

        case access_token
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.grantType = try container.decode(String.self, forKey: .grantType)
        self.tokenType = try container.decodeIfPresent(String.self, forKey: .tokenType)

        switch grantType {
        case "authorization_code":
            self.payload = .authorizationCode(
                AuthorizationCodePayload(
                    code: try container.decode(String.self, forKey: .code),
                    codeVerifier: try container.decodeIfPresent(String.self, forKey: .code_verifier)
                ))
        case "client_credentials":
            self.payload = .clientCredentials(ClientCredentialsPayload())
        // case "continuation_token":
        // self.payload = .continuationToken(ContinuationTokenPayload())
        case "device_auth":
            self.payload = .deviceAuth(
                DeviceAuthPayload(
                    accountId: try container.decode(String.self, forKey: .account_id),
                    deviceId: try container.decode(String.self, forKey: .device_id),
                    secret: try container.decode(String.self, forKey: .secret)))
        case "device_code":
            self.payload = .deviceCode(
                DeviceCodePayload(
                    deviceCode: try container.decode(String.self, forKey: .device_code)))
        case "exchange_code":
            self.payload = .exchangeCode(
                ExchangeCodePayload(
                    exchangeCode: try container.decode(String.self, forKey: .exchange_code),
                    codeVerifier: try container.decodeIfPresent(String.self, forKey: .code_verifier)
                ))
        case "external_auth":
            self.payload = .externalAuth(
                ExternalAuthPayload(
                    externalAuthType: try container.decode(
                        String.self, forKey: .external_auth_type),
                    externalAuthToken: try container.decode(
                        String.self, forKey: .external_auth_token)))
        case "otp":
            self.payload = .otp(
                OtpPayload(
                    otp: try container.decode(String.self, forKey: .otp),
                    challenge: try container.decode(String.self, forKey: .challenge)))
        case "password":
            self.payload = .password(
                PasswordPayload(
                    username: try container.decode(String.self, forKey: .username),
                    password: try container.decode(String.self, forKey: .password)))
        case "refresh_token":
            self.payload = .refreshToken(
                RefreshTokenPayload(
                    RefreshToken: try container.decode(String.self, forKey: .refresh_token)))
        case "token_to_token":
            self.payload = .tokenToToken(
                TokenToTokenPayload(
                    accessToken: try container.decode(String.self, forKey: .access_token))
            )
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .grantType,
                in: container,
                debugDescription: "Unsupported grantType: \(grantType)"
            )
        }
    }
}

struct TokenResponse: ResponseCodable {
    let accessToken: String
    let expiresIn: TimeInterval
    let expiresAt: Date
    let tokenType: String
    var refreshToken: String?
    var refreshExpires: TimeInterval?
    var refreshExpiresAt: Date?
    var accountId: String?
    let clientId: String
    let internalClient: Bool
    let clientService: String
    var scope: [String]?
    var displayName: String?
    var app: String?
    var inAppId: String?

    init(grantType: String, tokenType: String?, accessToken: String, clientId: String) {
        let now = Date()

        if tokenType == "eg1" {
            self.accessToken = accessToken.base64Encoded()!
        } else {
            self.accessToken = accessToken
        }

        self.tokenType = "bearer"
        self.clientId = clientId
        self.internalClient = true
        self.clientService = "fortnite"  // i think early versions use 'fortnite' and later 'prod-fn'

        switch grantType {
        case "client_credentials":
            let accessExpires: TimeInterval = 4 * 3600

            self.expiresIn = accessExpires
            self.expiresAt = now.advanced(by: accessExpires)
        default:
            let accessExpires: TimeInterval = 8 * 3600
            let refreshExpires: TimeInterval = 32 * 3600

            let refreshToken = "refresh_me"
            if tokenType == "eg1" {
                self.refreshToken = refreshToken.base64Encoded()!
            } else {
                self.refreshToken = refreshToken
            }

            self.expiresIn = accessExpires
            self.expiresAt = now.advanced(by: accessExpires)
            self.refreshExpires = refreshExpires
            self.refreshExpiresAt = now.advanced(by: refreshExpires)
            self.accountId = "8h9x"
            self.scope = []
            self.displayName = "8h9x"
            self.app = "fortnite"
            self.inAppId = "8h9x"
        }
    }
}
