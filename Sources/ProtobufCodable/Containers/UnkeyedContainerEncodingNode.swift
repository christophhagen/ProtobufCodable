import Foundation

final class UnkeyedContainerEncodingNode: CodingPathNode, UnkeyedEncodingContainer {

    private(set) var count: Int = 0

    private var nilIncides = Set<Int>()

    private var objects = [Data]()

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

    private func nilData(for key: CodingKey) throws -> Data {
        guard !nilIncides.isEmpty else {
            return .empty
        }
        let nilKey = NilCodingKey(codingKey: key)
        return try nilEncodingData.encoded(withKey: nilKey)
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
        let data = try primitive.encodedWithLengthIfNeeded()
        self.objects.append(data)
        if primitive.wireType == .lengthDelimited {
            canPackFields = false
        }
    }

    private func encodeChild(_ child: Encodable) throws {
        let encoder = TopLevelEncodingContainer(path: codingPath, key: key, userInfo: [:])
        try child.encode(to: encoder)
        let data = try encoder.encodedData()
        self.objects.append(data)
        canPackFields = false
    }

    // MARK: Children

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

extension UnkeyedContainerEncodingNode: EncodedDataProvider {

    func encodedData() throws -> Data {
        guard let key = key else {
            return nilEncodingData + objects.reduce(.empty, +)
        }
        let nilData = try self.nilData(for: key)
        if canPackFields {
            let packedValues = objects.reduce(.empty, +)
            guard !packedValues.isEmpty else {
                return nilData
            }
            return try nilData + packedValues.encoded(withKey: key)
        }
        // Encoding of unpacked fields already includes key and tag information
        return nilData + objects.reduce(.empty, +)
    }
}
