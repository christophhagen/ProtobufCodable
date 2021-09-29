import Foundation

final class DictionaryUnkeyedEncodingContainer: CodingPathNode, UnkeyedEncodingContainer {

    private enum DictCodingKey: Int, CodingKey {
        case key = 1
        case value = 2
    }

    private(set) var count: Int = 0

    private var keyData: Data?

    private var isEncodingKeyNext: Bool {
        keyData == nil
    }

    private var data: Data = .empty

    func encodeNil() throws {
        fatalError()
    }

    private func encode<T>(_ value: T, forKey key: DictCodingKey) throws -> Data where T: Encodable {
        switch value {
        case let primitive as BinaryEncodable:
            return try primitive.encoded(withKey: key)
        case let optionalValue as AnyOptional where optionalValue.isNil:
            return try NilContainer().encoded(withKey: key)
        default:
            let encoder = TopLevelEncodingContainer(path: codingPath + [key], key: key, userInfo: [:])
            try value.encode(to: encoder)
            return try encoder.encodedData()
        }
    }

    func encode<T>(_ value: T) throws where T : Encodable {
        guard let keyData = self.keyData else {
            keyData = try encode(value, forKey: .key)
            return
        }
        let valueData = try encode(value, forKey: .value)
        let keyValuePairData = keyData + valueData

        let data: Data
        if let key = self.key {
            data = try keyValuePairData.encoded(withKey: key)
        } else {
            data = try keyValuePairData.binaryData()
        }
        self.data.append(data)
        self.keyData = nil
        count += 1
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError()
    }

    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        fatalError()
    }

    func superEncoder() -> Encoder {
        fatalError()
    }
}

// MARK: EncodedDataProvider

extension DictionaryUnkeyedEncodingContainer: EncodedDataProvider {

    func encodedData() throws -> Data {
        data
    }
}
