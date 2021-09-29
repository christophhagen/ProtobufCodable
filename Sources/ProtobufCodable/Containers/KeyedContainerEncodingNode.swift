import Foundation

final class KeyedContainerEncodingNode<Key>: CodingPathNode, KeyedEncodingContainerProtocol where Key: CodingKey {

    private var data = Data()

    // MARK: Encoding

    func encodeNil(forKey key: Key) throws {
        fatalError()
    }

    /**
     Encodes the given value for the given key.
     - Parameter value: The value to encode.
     - Parameter key: The key to associate the value with.
     */
    func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        switch value {
        case let primitive as BinaryEncodable:
            // if primitive.isDefaultValue && omitDefaultValues { return }
            let data = try primitive.encoded(withKey: key)
            self.data.append(data)
        case is AnyDictionary:
            try encodeDictionary(value, forKey: key)
        default:
            try encodeChild(value, forKey: key)
        }
    }

    /**
     Encodes the given dictionary for the given key.

     A dictionary is encoded as a set of key-value pairs, which are encoded within a container using field ids 1 (key) and 2 (value).
     - Parameter dictionary: The value to encode.
     - Parameter key: The key to associate the value with.
     */
    private func encodeDictionary(_ dictionary: Encodable, forKey key: CodingKey) throws {
        let encoder = DictionaryEncodingNode(path: [], key: key, userInfo: [:])
        try dictionary.encode(to: encoder)
        let data = try encoder.encodedData()
        self.data.append(data)
    }

    /**
     Encodes a complex object for the given key.

     - Parameter child: The value to encode.
     - Parameter key: The key to associate the value with.
     */
    private func encodeChild(_ child: Encodable, forKey key: CodingKey) throws {
        let encoder = TopLevelEncodingContainer(path: codingPath + [key], key: key, userInfo: [:])
        try child.encode(to: encoder)
        let data = try encoder.encodedData()
        self.data.append(data)
    }

    private func tag(for key: CodingKey) throws -> Data {
        if let field = key.intValue {
            return WireType.lengthDelimited.tag(with: field)
        } else {
            fatalError()
        }
    }

    // MARK: Nesting

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError()
    }

    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        fatalError()
    }

    func superEncoder() -> Encoder {
        fatalError()
    }

    func superEncoder(forKey key: Key) -> Encoder {
        fatalError()
    }
}

// MARK: EncodedDataProvider

extension KeyedContainerEncodingNode: EncodedDataProvider {

    func encodedData() throws -> Data {
        if let key = self.key {
            return try data.encoded(withKey: key)
        }
        return data
    }
}
