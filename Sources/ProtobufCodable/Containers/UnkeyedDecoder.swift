import Foundation

private func decodeField(_ provider: DecodingDataProvider, nilData: Data?) throws -> DataWithNilIndex {
    let nilIndices: Set<Int>
    if let nilData = nilData {
        nilIndices = try decodeNilData(.init(data: nilData))
    } else {
        /// `nilData` is nil when using an unkeyed container on the top level,
        /// where no nil fields can be encoded with a nil index set in
        /// another field with a related key
        nilIndices = try decodeNilData(provider)
    }
    return .init(provider: provider, nilIndices: nilIndices)
}

private func decodeNilData(_ provider: DecodingDataProvider) throws -> Set<Int> {
    guard !provider.isAtEnd else {
        return []
    }
    let nilCount = try Int(from: provider)
    return Set(try (0..<nilCount).map { _ in try Int(from: provider) })
}

final class UnkeyedDecoder: CodingPathNode, UnkeyedDecodingContainer {

    let count: Int? = nil

    private var data: [DataWithNilIndex]

    private var current: DataWithNilIndex?

    var isAtEnd: Bool {
        current?.isAtEnd ?? true
    }

    var currentIndex: Int {
        current!.currentIndex
    }

    private var nextValueIsNil: Bool {
        current!.nilIndices.contains(currentIndex)
    }

    private func advanceToNextDataBlock() {
        while current?.isAtEnd ?? true {
            guard !data.isEmpty else {
                current = nil
                return
            }
            current = data.removeFirst()
        }
    }

    /**
     Create a node to decode unkeyed values (e.g. arrays)
     */
    init(path: [CodingKey], key: CodingKey?, info: [CodingUserInfoKey : Any], data: [FieldWithNilData]) throws {
        // For an unkeyed container, treat each data container
        // separately and decode the nil indices for each
        self.data = try data.map { field, nilData in
            return try decodeField(field, nilData: nilData)
        }

        super.init(path: path, key: key, info: info)
        advanceToNextDataBlock()
    }

    private func didDecodeValue() {
        current!.didDecodeValue()
        if current!.isAtEnd {
            advanceToNextDataBlock()
        }
    }

    func decodeNil() throws -> Bool {
        guard nextValueIsNil else {
            return false
        }
        didDecodeValue()
        return true
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        let provider = current!.provider
        switch type {
        case let Primitive as BinaryDecodable.Type:
            let value = try Primitive.init(includingLengthFrom: provider)
            didDecodeValue()
            return value as! T
        default:
            let provider = nextValueIsNil ? DecodingDataProvider(data: .empty) : provider
            let decoder = TopLevelDecoder(
                path: codingPath,
                key: nil,
                info: userInfo,
                data: [(field: provider, nilData: nil)])
            let value = try type.init(from: decoder)
            didDecodeValue()
            return value
        }
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        throw ProtobufDecodingError.notImplemented("UnkeyedContainer.nestedContainer(keyedBy:)")
    }

    func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        throw ProtobufDecodingError.notImplemented("UnkeyedContainer.nestedUnkeyedContainer()")
    }

    func superDecoder() throws -> Decoder {
        throw ProtobufDecodingError.notImplemented("UnkeyedContainer.superDecoder()")
    }
}
