import Foundation

final class KeyedContainerEncodingNode<Key>: KeyedEncodingContainerProtocol where Key: CodingKey {

    var codingPath: [CodingKey]

    private var objects = [EncodedDataWrapper]()

    init(codingPath: [CodingKey]) {
        self.codingPath = codingPath
    }

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
            let wrapper = try primitive.encoded(withKey: key)
            objects.append(wrapper)
        case is AnyDictionary:
            try encodeDictionary(value, forKey: key)
        default:
            try encodeChild(value, forKey: key)
        }
    }

    /**
     Encodes a primitive for the given key.

     A primitive is encoded using its wire type and field. Default values are omitted.
     - Parameter primitive: The value to encode.
     - Parameter key: The key to associate the value with.
     */
    private func encodePrimitive(_ primitive: BinaryEncodable, forKey key: CodingKey) throws {
        // if primitive.isDefaultValue && omitDefaultValues { return }
        let wrapper = try primitive.encoded(withKey: key)
        print("Key \(key.intValue!) - \(type(of: primitive)) (\(wrapper.wireType)): \(wrapper.data.count)")
        objects.append(wrapper)
    }

    /**
     Encodes the given dictionary for the given key.

     A dictionary is encoded as a set of key-value pairs, which are encoded within a container using field ids 1 (key) and 2 (value).
     - Parameter dictionary: The value to encode.
     - Parameter key: The key to associate the value with.
     */
    private func encodeDictionary(_ dictionary: Encodable, forKey key: CodingKey) throws {
        let encoder = DictionaryEncodingNode(codingPath: [], userInfo: [:])
        try dictionary.encode(to: encoder)
        let pairs = try encoder.encodedObjects()
        for pair in pairs {
            objects.append(pair.with(key: key))
        }
    }

    /**
     Encodes a complex object for the given key.

     - Parameter child: The value to encode.
     - Parameter key: The key to associate the value with.
     */
    private func encodeChild(_ child: Encodable, forKey key: CodingKey) throws {
        let encoder = TopLevelEncodingContainer(codingPath: codingPath + [key], userInfo: [:])
        try child.encode(to: encoder)
        let data = try encoder.encodedDataWithoutField(includeLengthIfNeeded: true)
        print("Key \(key.intValue!) - \(type(of: child)): \(data.count)")
        let preData = try encoder.encodedDataToPrepend()?.data
        if data.isEmpty && (preData?.isEmpty ?? true) {
            return
        }
        if let preData = preData, !preData.isEmpty {
            let nilKey = NilCodingKey(codingKey: key)
            objects.append(.init(preData, key: nilKey))
        }
        objects.append(.init(data, key: key))
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

    func encodedObjects() throws -> [EncodedDataWrapper] {
        objects
    }
}
