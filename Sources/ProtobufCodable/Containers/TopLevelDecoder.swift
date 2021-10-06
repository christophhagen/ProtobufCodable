import Foundation

typealias FieldWithNilData = (field: DecodingDataProvider, nilData: Data?)

final class TopLevelDecoder: CodingPathNode, Decoder {

    let userInfo: [CodingUserInfoKey : Any]
    
    private let data: [FieldWithNilData]

    init(path: [CodingKey], key: CodingKey?, info: [CodingUserInfoKey : Any], data: [FieldWithNilData]) {
        self.userInfo = info
        self.data = data
        super.init(path: path, key: key)
    }
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        let container = try KeyedDecoder<Key>(path: codingPath, key: key, data: data)
        return KeyedDecodingContainer<Key>(container)
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        try UnkeyedDecoder(path: codingPath, key: key, data: data)
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        SingleValueDecoder(path: codingPath, key: key, data: data)
    }
}
