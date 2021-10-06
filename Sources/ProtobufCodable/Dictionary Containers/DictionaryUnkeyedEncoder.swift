import Foundation

final class DictionaryUnkeyedEncoder: CodingPathNode, UnkeyedEncodingContainer {

    private enum DictCodingKey: Int, CodingKey {
        case key = 1
        case value = 2
    }

    private(set) var count: Int = 0

    private var keyData: Data?

    private var isEncodingKeyNext: Bool {
        keyData == nil
    }

    private var objects = [EncodedDataProvider]()

    func encodeNil() throws {
        throw ProtobufEncodingError.notImplemented("Dictionary.UnkeyedEncodingContainer.encodeNil()")
    }

    private func encode<T>(_ value: T, forKey key: DictCodingKey) throws -> Data where T: Encodable {
        switch value {
        case let primitive as BinaryEncodable:
            return try primitive.encoded(withKey: key)
        case let optionalValue as AnyOptional where optionalValue.isNil:
            return try NilContainer().encoded(withKey: key)
        default:
            let encoder = TopLevelEncoder(path: codingPath + [key], key: key, info: userInfo)
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
        self.objects.append(data)
        self.keyData = nil
        count += 1
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let container = KeyedEncoder<NestedKey>(path: codingPath, key: key, info: userInfo)
        self.objects.append(container)
        return KeyedEncodingContainer(container)
    }

    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        let container = UnkeyedEncoder(path: codingPath, key: key, info: userInfo)
        self.objects.append(container)
        return container
    }

    func superEncoder() -> Encoder {
        fatalError()
    }
}

// MARK: EncodedDataProvider

extension DictionaryUnkeyedEncoder: EncodedDataProvider {

    func encodedData() throws -> Data {
        try objects.reduce(.empty) { try $0 + $1.encodedData() }
    }
}
