import Foundation

struct UnsupportedUnkeyedEncoder: UnkeyedEncodingContainer {
    
    let codingPath: [CodingKey] = []
    
    let count: Int = 0
    
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
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        KeyedEncodingContainer(UnsupportedKeyedEncoder(error))
    }
    
    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        UnsupportedUnkeyedEncoder(error)
    }
    
    func superEncoder() -> Encoder {
        UnsupportedSuperEncoder(error)
    }

    func encode<T>(_ value: T) throws where T: Encodable {
        throw error
    }
}
