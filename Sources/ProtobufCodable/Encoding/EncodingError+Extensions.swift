import Foundation

extension EncodingError {
    
    static var notImplemented: EncodingError {
        .invalidValue(0, .init(codingPath: [], debugDescription: "Feature not implemented yet"))
    }
    
    static func unsupported(_ value: Any, _ message: String, codingPath: [CodingKey]) -> EncodingError {
        .invalidValue(value, .init(codingPath: codingPath, debugDescription: message))
    }
}
