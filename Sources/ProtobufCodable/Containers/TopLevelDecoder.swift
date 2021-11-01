import Foundation

final class TopLevelDecoder: CodingPathNode, Decoder {

    private let fields: [(key: CodingKey, data: FieldWithNilData)]?

    private let data: [FieldWithNilData]

    private let includesLength: Bool

    init(path: [CodingKey], key: CodingKey?, info: [CodingUserInfoKey : Any], data: [FieldWithNilData], includesLength: Bool = false) {
        self.data = data
        self.fields = nil
        self.includesLength = includesLength
        super.init(path: path, key: key, info: info)
    }

    init(path: [CodingKey], key: CodingKey?, info: [CodingUserInfoKey : Any], fields: [(key: CodingKey, data: FieldWithNilData)]) {
        self.fields = fields
        self.data = []
        self.includesLength = false
        super.init(path: path, key: key, info: info)
    }
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        if let fields = fields {
            let container = try KeyedDecoder<Key>(path: codingPath, key: key, info: userInfo, fields: fields)
            return KeyedDecodingContainer<Key>(container)
        }
        let container = try KeyedDecoder<Key>(path: codingPath, key: key, info: userInfo, data: data, includesLength: includesLength)
        return KeyedDecodingContainer<Key>(container)
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        try UnkeyedDecoder(path: codingPath, key: key, info: userInfo, data: data)
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        ValueDecoder(path: codingPath, key: key, info: userInfo, data: data, includesLength: includesLength)
    }
}
