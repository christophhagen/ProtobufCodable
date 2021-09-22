import Foundation

final class DictionaryUnkeyedDecodingContainer: UnkeyedDecodingContainer {

    var codingPath: [CodingKey]

    var count: Int?

    var isAtEnd: Bool {
        fields.isEmpty
    }

    private(set) var currentIndex: Int = 0

    private var fields = [(tag: Tag, data: Data)]()

    init(codingPath: [CodingKey], data: DecodingDataProvider) throws {
        self.codingPath = codingPath

        try decodeAllKeyValuePairs(provider: data)
    }

    private func decodeAllKeyValuePairs(provider: DecodingDataProvider) throws {
        while !provider.isAtEnd {
            try readKeyValuePair(provider: provider)
        }
    }

    private func readKeyValuePair(provider: DecodingDataProvider) throws {
        let data = try provider.getLengthEncodedField()
        let keyPairInterpreter = DecodingDataProvider(data: data)

        var key: (tag: Tag, data: Data)?
        var value: (tag: Tag, data: Data)?
        while !keyPairInterpreter.isAtEnd {
            let (t, d) = try keyPairInterpreter.getKeyedField()
            guard let codingKey = KeyValuePair<Int, Int>.CodingKeys(rawValue: t.field) else {
                fatalError()
            }
            switch codingKey {
            case .key:
                key = (tag: t, data: d)
            case .value:
                value = (tag: t, data: d)
            }
        }
        guard let (keyTag, keyData) = key, let (valueTag, valueData) = value else {
            fatalError()
        }
        self.fields.append((keyTag, keyData))
        self.fields.append((valueTag, valueData))
    }

    func decodeNil() throws -> Bool {
        fatalError()
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        guard !fields.isEmpty else {
            fatalError()
        }
        let (tag, data) = fields.remove(at: 0)
        switch type {
        case let Primitive as BinaryDecodable.Type:
            let value = try Primitive.init(encodedData: data)
            didDecodeValue()
            return value as! T
        case let OptionalValue as AnyOptional.Type:
            if data.isEmpty {
                return OptionalValue.nilValue as! T
            }
            let provider: DecodingDataProvider
            if tag.wireType == .lengthDelimited {
                provider = DecodingDataProvider(data: data.count.variableLengthEncoding +  data)
            } else {
                provider = DecodingDataProvider(data: data)
            }
            let decoder = TopLevelDecodingContainer(codingPath: codingPath, userInfo: [:], provider: provider)
            let value = try type.init(from: decoder)
            didDecodeValue()
            return value
        default:
            let provider = DecodingDataProvider(data: data)
            let decoder = TopLevelDecodingContainer(codingPath: codingPath, userInfo: [:], provider: provider)
            let value = try type.init(from: decoder)
            didDecodeValue()
            return value
        }
    }

    private func didDecodeValue() {
        currentIndex += 1
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError()
    }

    func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        fatalError()
    }

    func superDecoder() throws -> Decoder {
        fatalError()
    }



}
