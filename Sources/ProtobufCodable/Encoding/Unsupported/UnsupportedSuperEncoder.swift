import Foundation

struct UnsupportedSuperEncoder: Encoder {
    
    let codingPath: [CodingKey] = []
    
    let userInfo: [CodingUserInfoKey : Any] = [:]
    
    let error: EncodingError
    
    init(_ error: String) {
        self.error = EncodingError.unsupported(0, error, codingPath: [])
    }
    
    init(_ error: EncodingError) {
        self.error = error
    }
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        KeyedEncodingContainer(UnsupportedKeyedEncoder(error))
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        UnsupportedUnkeyedEncoder(error)
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        UnsupportedValueEncoder(error)
    }
}
