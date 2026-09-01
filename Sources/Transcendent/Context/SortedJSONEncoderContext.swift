import Foundation
import Hummingbird

struct SortedJSONEncoderContext: RequestContext {
    var coreContext: CoreRequestContextStorage

    var responseEncoder: JSONEncoder

    init(source: Source) {
        self.coreContext = .init(source: source)

        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        encoder.dateEncodingStrategy = .iso8601
        self.responseEncoder = encoder
    }
}
