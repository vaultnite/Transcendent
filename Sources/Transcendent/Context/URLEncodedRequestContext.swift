import Foundation
import Hummingbird

struct URLEncodedRequestContext: ChildRequestContext {
    typealias ParentContext = SortedJSONEncoderContext

    var requestDecoder: URLEncodedFormDecoder {
        .init()
    }
    var responseEncoder: JSONEncoder
    var coreContext: CoreRequestContextStorage

    init(source: Source) {
        self.coreContext = .init(source: source)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.responseEncoder = encoder
    }

    init(context: ParentContext) throws {
        self.coreContext = context.coreContext
        self.responseEncoder = context.responseEncoder
    }
}
