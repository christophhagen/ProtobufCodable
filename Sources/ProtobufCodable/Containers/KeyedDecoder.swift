import Foundation

final class KeyedDecoder<Key>: CodingPathNode, KeyedDecodingContainerProtocol where Key: CodingKey {

    var allKeys: [Key] {
        fields.compactMap { Key(key: $0.key) }
    }

    private var fields = [(key: CodingKey, data: FieldWithNilData)]()

    private let includesLength: Bool

    init(path: [CodingKey], key: CodingKey?, info: [CodingUserInfoKey : Any], fields: [(key: CodingKey, data: FieldWithNilData)]) throws {
        self.fields = fields
        self.includesLength = false
        super.init(path: path, key: key, info: info)
    }

    init(path: [CodingKey], key: CodingKey?, info: [CodingUserInfoKey : Any], data: [FieldWithNilData], includesLength: Bool = false) throws {
        self.includesLength = includesLength
        super.init(path: path, key: key, info: info)
        for (provider, _) in data {
            if includesLength {
                let data = try provider.getLengthEncodedField()
                try decodeAllFields(provider: .init(data: data))
            } else {
                try decodeAllFields(provider: provider)
            }
        }
    }

    /**
     Decode all fields in the given decoder.

     First extract the tag, and determine the length of the field. Remove the data for the field and continue
     the process until no more bytes remain.
     */
    private func decodeAllFields(provider: DecodingDataProvider) throws {
        var prevField: (key: CodingKey, data: Data)?
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
            let key = tag.key
            guard let prev = prevField else {
                prevField = (key, data)
                continue
            }
            guard prev.key.isEqual(to: key.correspondingNilKey) else {
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
        let nilKey = key.correspondingNilKey
        return fields.contains { $0.key.isEqual(to: key) || $0.key.isEqual(to: nilKey) }
    }

    func decodeNil(forKey key: Key) throws -> Bool {
        !contains(key)
    }

    private func getData(for key: Key) -> [FieldWithNilData] {
        let nilKey = key.correspondingNilKey
        defer {
            fields = fields.filter { !$0.key.isEqual(to: key) && !$0.key.isEqual(to: nilKey)  }
        }
        return fields.compactMap {
            if $0.key.isEqual(to: key) {
                return $0.data
            }
            if $0.key.isEqual(to: nilKey) {
                // Fields may exist where only nil data has been encoded
                // In this case, use empty value data with the nil data
                return (field: .empty, nilData: $0.data.field.getRemainingBytes())
            }
            return nil
        }
    }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        let newPath = codingPath + [key]
        // Find all fields with the appropriate key and join them together
        let all = getData(for: key)

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
            let decoder = DictionaryDecoder(path: newPath, key: key, info: userInfo, data: all)
            return try .init(from: decoder)
        default:
            // Get nil fields if it exists
            let decoder = TopLevelDecoder(
                path: newPath,
                key: key,
                info: userInfo,
                data: all)
            return try T.init(from: decoder)
        }
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        // Find all fields with the appropriate key and join them together
        let all = getData(for: key)
        let container = try KeyedDecoder<NestedKey>(path: codingPath + [key], key: key, info: userInfo, data: all)
        return KeyedDecodingContainer(container)
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        let all = getData(for: key)
        return try UnkeyedDecoder(path: codingPath, key: key, info: userInfo, data: all)
    }

    func superDecoder() throws -> Decoder {
        return TopLevelDecoder(path: codingPath, key: key, info: userInfo, fields: fields)
    }

    func superDecoder(forKey key: Key) throws -> Decoder {
        let all = getData(for: key)
        return TopLevelDecoder(path: codingPath, key: key, info: userInfo, data: all)
    }
}
