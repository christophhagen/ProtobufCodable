import Foundation

final class DictionaryDecoder: CodingPathNode, Decoder {

    let data: [FieldWithNilData]

    init(path: [CodingKey], key: CodingKey?, info: [CodingUserInfoKey : Any], data: [FieldWithNilData]) {
        self.data = data
        super.init(path: path, key: key, info: info)
    }

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        let container = try DictionaryKeyedDecoder<Key>(path: codingPath, key: key, info: userInfo, data: data)
        return KeyedDecodingContainer<Key>(container)
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        try DictionaryUnkeyedDecoder(path: codingPath, key: key, info: userInfo, data: data)
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        throw ProtobufDecodingError.notImplemented("Dictionary.singleValueContainer()")
    }
}
