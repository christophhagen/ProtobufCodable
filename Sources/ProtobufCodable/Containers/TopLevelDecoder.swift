import Foundation

typealias FieldWithNilData = (field: DecodingDataProvider, nilData: Data?)

final class TopLevelDecoder: CodingPathNode, Decoder {

    private let data: [FieldWithNilData]

    init(path: [CodingKey], key: CodingKey?, info: [CodingUserInfoKey : Any], data: [FieldWithNilData]) {
        self.data = data
        super.init(path: path, key: key, info: info)
    }
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        let container = try KeyedDecoder<Key>(path: codingPath, key: key, info: userInfo, data: data)
        return KeyedDecodingContainer<Key>(container)
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        try UnkeyedDecoder(path: codingPath, key: key, info: userInfo, data: data)
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        SingleValueDecoder(path: codingPath, key: key, info: userInfo, data: data)
    }
}
