import Foundation

final class TopLevelDecodingNode: Decoder {
    var codingPath: [CodingKey]
    
    var userInfo: [CodingUserInfoKey : Any]
    
    let data: Data
    
    init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any], data: Data) {
        self.codingPath = codingPath
        self.userInfo = userInfo
        self.data = data
    }
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        fatalError()
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        fatalError()
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        SingleValueDecodingNode(codingPath: codingPath, data: data)
    }
}
