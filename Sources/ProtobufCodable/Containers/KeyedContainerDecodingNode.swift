import Foundation

private extension CodingKey {

    func isEqual(to other: CodingKey) -> Bool {
        if let ownInt = intValue, let otherInt = other.intValue {
            return ownInt == otherInt
        }
        return stringValue == other.stringValue
    }
}

final class KeyedContainerDecodingNode<Key>: CodingPathNode, KeyedDecodingContainerProtocol where Key: CodingKey {

    var allKeys: [Key] {
        fields.map { $0.key }
    }

    private var fields = [(key: Key, data: FieldWithNilData)]()

    init(path: [CodingKey], key: CodingKey?, data: [FieldWithNilData]) throws {
        super.init(path: path, key: key)
        for (provider, _) in data {
            try decodeAllFields(provider: provider)
        }
    }

    /**
     Decode all fields in the given decoder.

     First extract the tag, and determine the length of the field. Remove the data for the field and continue
     the process until no more bytes remain.
     */
    private func decodeAllFields(provider: DecodingDataProvider) throws {
        var prevField: (key: Key, data: Data)?
        while !provider.isAtEnd {
            let tag = try Tag(from: provider)

            let data: Data
            if let length = tag.valueLength {
                data = try provider.getNextBytes(length)
            } else if tag.wireType == .lengthDelimited {
                let length = try Int(from: provider)
                data = try provider.getNextBytes(length)
            } else {
                // Only choice left is varint
                data = try provider.extractVarint()
            }
            guard let key = Key(intValue: tag.field) else {
                fatalError()
                continue
            }
            guard let prev = prevField else {
                prevField = (key, data)
                continue
            }
            guard prev.key.isEqual(to: NilCodingKey(codingKey: key)) else {
                let fieldData: FieldWithNilData = (.init(data: prev.data), .empty)
                fields.append((key: prev.key, data: fieldData))
                prevField = (key, data)
                continue
            }
            let fieldData: FieldWithNilData = (.init(data: data), prev.data)
            fields.append((key: key, data: fieldData))
            prevField = nil
        }
        guard let prev = prevField else {
            return
        }
        let fieldData: FieldWithNilData = (.init(data: prev.data), .empty)
        fields.append((key: prev.key, data: fieldData))
    }

    // MARK: Decoding

    func contains(_ key: Key) -> Bool {
        fatalError()
    }

    func decodeNil(forKey key: Key) throws -> Bool {
        fatalError()
    }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        let newPath = codingPath + [key]
        // Find all fields with the appropriate key and join them together
        let all: [FieldWithNilData] = fields
            .filter { $0.key.isEqual(to: key) }
            .map { $0.data }

        switch type {
        case let Primitive as BinaryDecodable.Type:
            guard let lastValue = all.last?.field else {
                return Primitive.defaultValue as! T
            }
            return try Primitive.init(from: lastValue) as! T
        case let Dict as AnyDictionary.Type:
            // Not really needed to catch empty dicts, but maybe a bit more performant
            guard !all.isEmpty else {
                return Dict.init() as! T
            }
            // Merge all fields together
            #warning("Add length back to items in 'all'?")
            let decoder = DictionaryDecodingNode(path: newPath, key: key, userInfo: [:], data: all)
            return try .init(from: decoder)
        default:
            // Get nil fields if it exists
            let decoder = TopLevelDecodingContainer(
                path: newPath,
                key: key,
                info: [:],
                data: all)
            return try T.init(from: decoder)
        }
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError()
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        fatalError()
    }

    func superDecoder() throws -> Decoder {
        fatalError()
    }

    func superDecoder(forKey key: Key) throws -> Decoder {
        fatalError()
    }
}
