import Foundation

final class DictionaryUnkeyedEncodingContainer: UnkeyedEncodingContainer {

    private enum DictCodingKey: Int, CodingKey {
        case key = 1
        case value = 2
    }

    let codingPath: [CodingKey]

    private(set) var count: Int = 0

    private var keyData: Data?

    private var isEncodingKeyNext: Bool {
        keyData == nil
    }

    private var objects = [Data]()

    init(codingPath: [CodingKey]) {
        self.codingPath = codingPath
    }

    func encodeNil() throws {
        fatalError()
    }

    private func encode<T>(_ value: T, forKey key: DictCodingKey) throws -> Data where T: Encodable {
        switch value {
        case let primitive as BinaryEncodable:
            let data = try primitive.binaryDataIncludingLengthIfNeeded()
            let tag = primitive.wireType.tag(with: key.rawValue)
            return tag + data
        case let optional as AnyOptional where optional.isNil:
            return WireType.nilValue.tag(with: key.rawValue)
        default:
            let encoder = TopLevelEncodingContainer(codingPath: codingPath + [key], userInfo: [:])
            try value.encode(to: encoder)
            let data = try encoder.getEncodedData()
            let tag: Data
            if let field = key.intValue {
                tag = WireType.lengthDelimited.tag(with: field)
            } else {
                fatalError()
            }
            return tag + data.count.binaryData() + data
        }
    }

    func encode<T>(_ value: T) throws where T : Encodable {
        guard let keyData = self.keyData else {
            keyData = try encode(value, forKey: .key)
            return
        }
        let valueData = try encode(value, forKey: .value)
        let data = keyData + valueData
        let length = data.count.variableLengthEncoding
        self.objects.append(length + data)
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

    func getEncodedData() throws -> Data {
        self.objects.reduce(.empty, +)
    }

    func encodedObjects() throws -> [Data] {
        self.objects
    }
}
