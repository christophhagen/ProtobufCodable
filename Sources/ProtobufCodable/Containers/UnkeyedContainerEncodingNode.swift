import Foundation

final class UnkeyedContainerEncodingNode: UnkeyedEncodingContainer {

    let codingPath: [CodingKey]

    private(set) var count: Int = 0

    private var nilIncides = Set<Int>()

    private var objects = [EncodedDataWrapper]()

    var isEncodingOnlyScalarValues = true

    init(codingPath: [CodingKey]) {
        self.codingPath = codingPath
    }

    // MARK: Encoding values

    var encodedNilIndices: Data {
        nilIncides.sorted().map { $0.variableLengthEncoding }.reduce(.empty, +)
    }

    var nilEncodingData: Data {
        let countData = nilIncides.count.variableLengthEncoding
        return countData + encodedNilIndices
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
        let wrapper = try primitive.encoded()
        objects.append(wrapper)
        if primitive.wireType == .lengthDelimited {
            isEncodingOnlyScalarValues = false
        }
    }

    private func encodeChild(_ child: Encodable) throws {
        let encoder = TopLevelEncodingContainer(codingPath: codingPath, userInfo: [:])
        try child.encode(to: encoder)
        let data = try encoder.encodedDataWithoutField(includeLengthIfNeeded: false)
        // Object may be empty, but must still be encoded in an unkeyed container
        print("\(type(of: child)): \(data.count)")
        objects.append(.init(data))
        isEncodingOnlyScalarValues = false
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

    func encodedObjects() throws -> [EncodedDataWrapper] {
        objects
    }

    func encodedDataToPrepend() throws -> EncodedDataWrapper? {
        .init(encodedNilIndices)
    }
}
