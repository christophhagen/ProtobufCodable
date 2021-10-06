import Foundation

final class KeyedEncoder<Key>: CodingPathNode, KeyedEncodingContainerProtocol where Key: CodingKey {

    private var objects = [EncodedDataProvider]()

    // MARK: Encoding

    func encodeNil(forKey key: Key) throws {
        throw ProtobufEncodingError.notImplemented("KeyedEncodingContainer.encodeNil(forKey:)")
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
            self.objects.append(data)
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
        let encoder = DictionaryEncoder(path: [], key: key, userInfo: [:])
        try dictionary.encode(to: encoder)
        self.objects.append(encoder)
    }

    /**
     Encodes a complex object for the given key.

     - Parameter child: The value to encode.
     - Parameter key: The key to associate the value with.
     */
    private func encodeChild(_ child: Encodable, forKey key: CodingKey) throws {
        let encoder = TopLevelEncoder(path: codingPath + [key], key: key, userInfo: [:])
        try child.encode(to: encoder)
        self.objects.append(encoder)
    }

    // MARK: Nesting

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let container = KeyedEncoder<NestedKey>(path: codingPath + [key], key: key)
        self.objects.append(container)
        return KeyedEncodingContainer(container)
    }

    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        let container = UnkeyedEncoder(path: codingPath + [key], key: key)
        self.objects.append(container)
        return container
    }

    func superEncoder() -> Encoder {
        fatalError()
    }

    func superEncoder(forKey key: Key) -> Encoder {
        fatalError()
    }
}

// MARK: EncodedDataProvider

extension KeyedEncoder: EncodedDataProvider {

    func encodedData() throws -> Data {
        let data = try objects.reduce(.empty) { try $0 + $1.encodedData() }
        if let key = self.key {
            return try data.encoded(withKey: key)
        }
        return data
    }
}
