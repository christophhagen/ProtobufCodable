import Foundation

/**
 A simple wrapper for primitive values so that they can be encoded in an unkeyed container.
 */
private struct PrimitiveContainer {

    let primitive: BinaryEncodable

    init(_ primitive: BinaryEncodable) {
        self.primitive = primitive
    }
}

extension PrimitiveContainer: EncodedDataProvider {

    func encodedData() throws -> Data {
        try primitive.encodedWithLengthIfNeeded()
    }

    func encodedDataWithKeys(_ key: CodingKey, requireIntegerKey: Bool) throws -> Data {
        try primitive.encoded(withKey: key, requireIntegerKey: requireIntegerKey)
    }
}

/**
 A container for unkeyed values, like arrays and sets.
 */
final class UnkeyedEncoder: ObjectEncoder, UnkeyedEncodingContainer {

    private(set) var count: Int = 0

    private var nilIncides = Set<Int>()

    /**
     Indicate if the repeated values can be "packed".

     - SeeAlso: [Protobuf Encoding](https://developers.google.com/protocol-buffers/docs/encoding#packed)
     */
    var canPackFields = true

    // MARK: Encoding values

    var encodedNilIndices: Data {
        nilIncides.sorted().map { $0.variableLengthEncoding }.reduce(.empty, +)
    }

    var nilEncodingData: Data {
        let countData = nilIncides.count.variableLengthEncoding
        return countData + encodedNilIndices
    }

    /**
     An empty array of nil indices to be used when distinguishing between `nil` and an empty array.
     - Parameter key: The key to convert to a nil key.
     */
    func emptyNilData(for key: CodingKey) -> Data {
        // Never throws since only `binaryData()` for `Data` is called
        try! Data([0]).encoded(withKey: key.correspondingNilKey, requireIntegerKey: requireIntegerCodingKeys)
    }

    func valueData() throws -> Data {
        try objects.reduce(.empty) { try $0 + $1.encodedData() }
    }

    func valueDataWithLengths() throws -> Data {
        try objects.reduce(.empty) {
            let data = try $1.encodedData()
            return $0 + data.count.binaryData() + data
        }
    }

    private func nilData(for key: CodingKey) throws -> Data {
        if nilIncides.isEmpty {
            return .empty
        }
        return try nilEncodingData.encoded(withKey: key.correspondingNilKey, requireIntegerKey: requireIntegerCodingKeys)
    }

    func encodeNil() throws {
        nilIncides.insert(count)
    }

    func encode<T>(_ value: T) throws where T : Encodable {
        switch value {
        case let primitive as BinaryEncodable:
            try encodePrimitive(primitive)
        case let optional as Optional<Any> where optional == nil:
            try encodeNil()
        default:
            try encodeChild(value)
        }
        count += 1
    }

    private func encodePrimitive(_ primitive: BinaryEncodable) throws {
        addObject {
            PrimitiveContainer(primitive)
        }
        if primitive.wireType == .lengthDelimited {
            canPackFields = false
        }
    }

    private func encodeChild(_ child: Encodable) throws {
        let encoder = addObject {
            TopLevelEncoder(path: codingPath, key: key, info: userInfo, requiresLength: isAtTopLevel)
        }
        try child.encode(to: encoder)
        canPackFields = false
    }

    // MARK: Children

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let container = addObject {
            KeyedEncoder<NestedKey>(path: codingPath, key: key, info: userInfo)
        }
        return KeyedEncodingContainer(container)
    }

    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        addObject {
            UnkeyedEncoder(path: codingPath, key: key, info: userInfo)
        }
    }

    func superEncoder() -> Encoder {
        fatalError()
    }
}

// MARK: EncodedDataProvider

extension UnkeyedEncoder: EncodedDataProvider {

    func encodedData() throws -> Data {
        guard let key = key else {
            return try nilEncodingData + valueData()
        }
        if objects.isEmpty && nilIncides.isEmpty && !omitDefaultValues {
            // An empty array of nil indices prevents an empty array from decoding as `nil`
            // The nil data is omitted if defaults are not being encoded
            return emptyNilData(for: key)
        }
        let nilData = try self.nilData(for: key)
        guard canPackFields else {
            // Encoding of unpacked fields already includes key and tag information
            return try nilData + objects.reduce(.empty) {
                try $0 + $1.encodedDataWithKeys(key, requireIntegerKey: requireIntegerCodingKeys)
            }
        }
        let valueData = try valueData()
        guard !valueData.isEmpty else {
            return nilData
        }
        return try nilData + valueData.encoded(withKey: key, requireIntegerKey: requireIntegerCodingKeys)
    }
}
