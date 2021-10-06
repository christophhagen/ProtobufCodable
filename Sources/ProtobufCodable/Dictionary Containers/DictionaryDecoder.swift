import Foundation

final class DictionaryDecoder: CodingPathNode, Decoder {

    let userInfo: [CodingUserInfoKey : Any]

    let data: [FieldWithNilData]

    init(path: [CodingKey], key: CodingKey?, userInfo: [CodingUserInfoKey : Any], data: [FieldWithNilData]) {
        self.userInfo = userInfo
        self.data = data
        super.init(path: path, key: key)
    }

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        let container = try DictionaryKeyedDecoder<Key>(path: codingPath, key: key, data: data)
        return KeyedDecodingContainer<Key>(container)
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        try DictionaryUnkeyedDecoder(path: codingPath, key: key, data: data)
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        throw ProtobufDecodingError.notImplemented("Dictionary.singleValueContainer()")
    }
}
