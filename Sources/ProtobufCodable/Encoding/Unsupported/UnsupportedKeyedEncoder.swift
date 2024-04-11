import Foundation

/**
 - Note: Only called from within unkeyed container at the top level
 */
struct UnsupportedKeyedEncoder<Key>: KeyedEncodingContainerProtocol where Key: CodingKey {
   
    let codingPath: [CodingKey] = []
    
    let error: EncodingError
    
    init(_ error: String) {
        self.error = EncodingError.unsupported(0, error, codingPath: [])
    }
    
    init(_ error: EncodingError) {
        self.error = error
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        KeyedEncodingContainer(UnsupportedKeyedEncoder<NestedKey>(error))
    }
    
    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        UnsupportedUnkeyedEncoder(error)
    }
    
    func superEncoder() -> Encoder {
        UnsupportedSuperEncoder(error)
    }
    
    func superEncoder(forKey key: Key) -> Encoder {
        superEncoder()
    }
    
    func encodeNil(forKey key: Key) throws {
        throw error
    }
    
    func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        throw error
    }
}
