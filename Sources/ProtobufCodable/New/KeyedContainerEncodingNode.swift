import Foundation

final class KeyedContainerEncodingNode<Key>: KeyedEncodingContainerProtocol where Key: CodingKey {

    var codingPath: [CodingKey]

    private var encodedChildren = [Data]()

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
        guard let field = key.intValue else {
            throw ProtobufEncodingError.missingIntegerCodingKey(key)
        }
        switch value {
        case let primitive as BinaryEncodable:
            try encodePrimitive(primitive, forKey: field)
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
    private func encodePrimitive(_ primitive: BinaryEncodable, forKey key: Int) throws {
//        if primitive.isDefaultValue && omitDefaultValues {
//            return
//        }
        let data = try primitive.binaryDataIncludingLengthIfNeeded()
        let tag = primitive.wireType.tag(with: key)
        encodedChildren.append(tag + data)
    }

    /**
     Encodes the given dictionary for the given key.

     A dictionary is encoded as a set of key-value pairs, which are encoded within a container using field ids 1 (key) and 2 (value).
     - Parameter dictionary: The value to encode.
     - Parameter key: The key to associate the value with.
     */
    private func encodeDictionary(_ dictionary: Encodable, forKey key: CodingKey) throws {
        let tag = try tag(for: key)
        let encoder = DictionaryEncodingNode(codingPath: [], userInfo: [:])
        try dictionary.encode(to: encoder)
        let objects = try encoder.encodedObjects()
        encodedChildren.append(objects.map { tag + $0}.reduce(.empty, +))
    }

    /**
     Encodes a complex object for the given key.

     - Parameter child: The value to encode.
     - Parameter key: The key to associate the value with.
     */
    private func encodeChild(_ child: Encodable, forKey key: CodingKey) throws {
        let tag = try self.tag(for: key)
        let encoder = TopLevelEncodingContainer(codingPath: codingPath + [key], userInfo: [:])
        try child.encode(to: encoder)
        let data = try encoder.getEncodedData()
//        guard !data.isEmpty else {
//            return
//        }
        encodedChildren.append(tag + data.count.binaryData() + data)
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

    func getEncodedData() throws -> Data {
        encodedChildren.reduce(.empty, +)
    }

    func encodedObjects() throws -> [Data] {
        encodedChildren
    }
}
