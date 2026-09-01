// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import Hummingbird;

struct ErrorRequestContext: RequestContext {
    var coreContext: CoreRequestContextStorage

    init(source: Source) {
        self.coreContext = .init(source: source)
    }
}

@main
struct Transcendent {
    static func main() async throws {
        print("Hello, world!")

        let router = Router(context: SortedJSONEncoderContext.self)

        router.add(middleware: ErrorTransformer())

        AccountController().addRoutes(to: router.group("account/api", context: URLEncodedRequestContext.self))

        let app = Application(router: router, configuration: .init(address: .hostname("0.0.0.0", port: 8080)))

        try await app.runService()
    }
}

extension String {
    func base64Encoded() -> String? {
        guard let data = self.data(using: .utf8) else { return nil }
        return data.base64EncodedString()
    }
}
