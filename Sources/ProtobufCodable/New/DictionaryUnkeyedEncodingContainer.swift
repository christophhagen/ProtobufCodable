import Foundation

final class DictionaryUnkeyedEncodingContainer: UnkeyedEncodingContainer {

    private enum DictCodingKey: Int, CodingKey {
        case key = 1
        case value = 2
    }

    let codingPath: [CodingKey]

    private(set) var count: Int = 0

    private var keyData: EncodedDataWrapper?

    private var isEncodingKeyNext: Bool {
        keyData == nil
    }

    private var objects = [EncodedDataWrapper]()

    init(codingPath: [CodingKey]) {
        self.codingPath = codingPath
    }

    func encodeNil() throws {
        fatalError()
    }

    private func encode<T>(_ value: T, forKey key: DictCodingKey) throws -> EncodedDataWrapper where T: Encodable {
        switch value {
        case let primitive as BinaryEncodable:
            return try primitive.encoded(withKey: key)
        case let optionalValue as AnyOptional where optionalValue.isNil:
            return .init(.empty, wireType: .nilValue, key: key)
        default:
            let encoder = TopLevelEncodingContainer(codingPath: codingPath + [key], userInfo: [:])
            try value.encode(to: encoder)
            let data = try encoder.encodedDataWithoutField(includeLengthIfNeeded: true)
            return .init(data, key: key)
        }
    }

    func encode<T>(_ value: T) throws where T : Encodable {
        guard let keyData = self.keyData else {
            keyData = try encode(value, forKey: .key)
            return
        }
        let valueData = try encode(value, forKey: .value)
        let data = keyData.encoded() + valueData.encoded()
        let wrapper = EncodedDataWrapper(data)
        self.objects.append(wrapper)
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

    func encodedObjects() throws -> [EncodedDataWrapper] {
        self.objects
    }
}
