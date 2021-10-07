import Foundation

typealias FieldWithNilData = (field: DecodingDataProvider, nilData: Data?)

final class TopLevelDecoder: CodingPathNode, Decoder {

    private let fields: [(key: CodingKey, data: FieldWithNilData)]?

    private let data: [FieldWithNilData]

    init(path: [CodingKey], key: CodingKey?, info: [CodingUserInfoKey : Any], data: [FieldWithNilData]) {
        self.data = data
        self.fields = nil
        super.init(path: path, key: key, info: info)
    }

    init(path: [CodingKey], key: CodingKey?, info: [CodingUserInfoKey : Any], fields: [(key: CodingKey, data: FieldWithNilData)]) {
        self.fields = fields
        self.data = []
        super.init(path: path, key: key, info: info)
    }
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        if let fields = fields {
            let container = try KeyedDecoder<Key>(path: codingPath, key: key, info: userInfo, fields: fields)
            return KeyedDecodingContainer<Key>(container)
        }
        let container = try KeyedDecoder<Key>(path: codingPath, key: key, info: userInfo, data: data)
        return KeyedDecodingContainer<Key>(container)
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        try UnkeyedDecoder(path: codingPath, key: key, info: userInfo, data: data)
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        ValueDecoder(path: codingPath, key: key, info: userInfo, data: data)
    }
}
