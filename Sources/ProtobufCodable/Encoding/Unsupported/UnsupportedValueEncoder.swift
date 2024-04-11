import Foundation

struct UnsupportedValueEncoder: SingleValueEncodingContainer {
    
    let codingPath: [CodingKey] = []
    
    let error: EncodingError
    
    init(_ error: String) {
        self.error = EncodingError.unsupported(0, error, codingPath: [])
    }
    
    init(_ error: EncodingError) {
        self.error = error
    }
    
    func encodeNil() throws {
        throw error
    }
    
    func encode<T>(_ value: T) throws where T : Encodable {
        throw error
    }
}
