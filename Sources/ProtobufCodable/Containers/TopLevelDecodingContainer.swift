import Foundation

final class TopLevelDecodingContainer: Decoder {

    var codingPath: [CodingKey]
    
    var userInfo: [CodingUserInfoKey : Any]
    
    let data: DecodingDataProvider

    init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any], data: Data) {
        self.codingPath = codingPath
        self.userInfo = userInfo
        self.data = DecodingDataProvider(data: data)
    }

    init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any], provider: DecodingDataProvider) {
        self.codingPath = codingPath
        self.userInfo = userInfo
        self.data = provider
    }
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        let container = try KeyedContainerDecodingNode<Key>(codingPath: codingPath, provider: data)
        return KeyedDecodingContainer<Key>(container)
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        try UnkeyedContainerDecodingNode(codingPath: codingPath, provider: data)
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        SingleValueDecodingNode(codingPath: codingPath, provider: data)
    }
}
