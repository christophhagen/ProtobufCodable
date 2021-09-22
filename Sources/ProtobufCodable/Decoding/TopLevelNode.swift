import Foundation

/*
final class TopLevelNode: Decoder {
    
    var codingPath: [CodingKey]
    
    var userInfo: [CodingUserInfoKey : Any]
    
    private var wrappedContainer: WrappedContainer?
    
    init(data: Data) {
        self.userInfo = [:]
        codingPath = []
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        throw DecodingError.dataCorrupted(.init(codingPath: codingPath, debugDescription: #function))
        // UnkeyedDecoder(decoder: self, data: data, parent: self)
    }
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        throw DecodingError.dataCorrupted(.init(codingPath: codingPath, debugDescription: #function))
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        throw DecodingError.dataCorrupted(.init(codingPath: codingPath, debugDescription: #function))
    }
    
}


protocol WrappedContainer {
    
}
*/
