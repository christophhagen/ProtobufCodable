import Foundation

final class DictionaryUnkeyedDecodingContainer: CodingPathNode, UnkeyedDecodingContainer {

    var count: Int?

    var isAtEnd: Bool {
        fields.isEmpty
    }

    private(set) var currentIndex: Int = 0

    private var fields = [(tag: Tag, data: Data)]()

    init(path: [CodingKey], key: CodingKey?, data: [FieldWithNilData]) throws {
        super.init(path: path, key: key)

        for (provider, _) in data {
            try decodeAllKeyValuePairs(provider: provider)
        }
    }

    private func decodeAllKeyValuePairs(provider: DecodingDataProvider) throws {
        while !provider.isAtEnd {
            try readKeyValuePair(provider: provider)
        }
    }

    private func readKeyValuePair(provider: DecodingDataProvider) throws {

        var key: (tag: Tag, data: Data)?
        var value: (tag: Tag, data: Data)?
        while key == nil || value == nil {
            let (t, d) = try provider.getKeyedField()
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
        self.fields.append((key!.tag, key!.data))
        self.fields.append((value!.tag, value!.data))
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
            let decoder = TopLevelDecodingContainer(path: codingPath, key: key, info: [:], data: [(provider, nil)])
            let value = try type.init(from: decoder)
            didDecodeValue()
            return value
        default:
            let provider = DecodingDataProvider(data: data)
            let decoder = TopLevelDecodingContainer(path: codingPath, key: key, info: [:], data: [(provider, nil)])
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
