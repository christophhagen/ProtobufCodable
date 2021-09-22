import Foundation

final class UnkeyedContainerEncodingNode: UnkeyedEncodingContainer {

    let codingPath: [CodingKey]

    private(set) var count: Int = 0

    private var nilIncides = Set<Int>()

    private var objects = [EncodedDataWrapper]()

    init(codingPath: [CodingKey]) {
        self.codingPath = codingPath
    }

    // MARK: Encoding values

    var nilEncodingData: Data {
        let countData = nilIncides.count.variableLengthEncoding
        let valueData = nilIncides.sorted().map { $0.variableLengthEncoding }.reduce(.empty, +)
        return countData + valueData
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
        objects.append(try primitive.encoded())
    }

    private func encodeChild(_ child: Encodable) throws {
        let encoder = TopLevelEncodingContainer(codingPath: codingPath, userInfo: [:])
        try child.encode(to: encoder)
        let data = try encoder.encodedDataWithoutField(includeLengthIfNeeded: false)
        objects.append(.init(data))
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

    func encodedDataToPrepend() throws -> Data {
        nilEncodingData
    }
}
