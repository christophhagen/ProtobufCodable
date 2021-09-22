import Foundation

final class DictionaryDecodingNode: Decoder {

    let codingPath: [CodingKey]

    let userInfo: [CodingUserInfoKey : Any]

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
        let container = try DictionaryKeyedDecodingContainer<Key>(codingPath: codingPath, provider: data)
        return KeyedDecodingContainer<Key>(container)
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        try DictionaryUnkeyedDecodingContainer(codingPath: codingPath, data: data)
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        fatalError()
    }
}
