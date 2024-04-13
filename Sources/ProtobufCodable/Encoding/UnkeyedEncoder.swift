import Foundation

final class UnkeyedEncoder: AbstractEncodingNode, UnkeyedEncodingContainer {

    private var encodedValues: [EncodableContainer] = []

    private var firstEncodedType: Any.Type? = nil

    private var encodedDataType: WireType = .len

    var count: Int {
        encodedValues.count
    }

    func encodeNil() throws {
        throw EncodingError.unsupported(0, "Encoding nil is not supported in unkeyed containers", codingPath: codingPath)
    }

    @discardableResult
    private func add<T>(_ value: T) -> T where T: EncodableContainer {
        encodedValues.append(value)
        return value
    }

    private func addedNode() -> EncodingNode {
        let node = EncodingNode(codingPath: codingPath, userInfo: userInfo)
        return add(node)
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        KeyedEncodingContainer(add(KeyedEncoder(codingPath: codingPath, userInfo: userInfo)))
    }

    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        UnsupportedUnkeyedEncoder("Nested unkeyed container not supported in unkeyed container")
    }

    func superEncoder() -> Encoder {
        UnsupportedSuperEncoder("Encoding super in unkeyed containers is not supported")
    }

    private func ensureTypeMatches<T>(for value: T, wireType: WireType) throws {
        guard let firstEncodedType else {
            self.firstEncodedType = T.self
            self.encodedDataType = wireType
            return
        }
        guard T.self != firstEncodedType else {
            return
        }
        throw EncodingError.unsupported(value, "Unkeyed container only supports elements of a single type (previously encoded \(firstEncodedType))", codingPath: codingPath)
    }

    func encode<T>(_ value: T) throws where T : Encodable {
        if value is UnsupportedEncodable {
            throw EncodingError.unsupported(value, "Unsupported value of type \(T.self) in unkeyed encoder", codingPath: codingPath)
        }
        if value is AnyDictionary {
            throw EncodingError.unsupported(value, "Protobuf does not support repeated map fields", codingPath: codingPath)
        }
        if T.self is EncodablePrimitive.Type, let base = value as? EncodablePrimitive {
            try ensureTypeMatches(for: value, wireType: base.wireType)
            add(base)
            return
        }
        // All non-primitive types are of type `len`
        try ensureTypeMatches(for: value, wireType: .len)
        let encoder = EncodingNode(codingPath: codingPath, userInfo: userInfo)
        try value.encode(to: encoder)
        add(encoder)
    }

}

extension UnkeyedEncoder: EncodableContainer {

    func encode(forKey key: Int) throws -> Data {
        guard !encodedValues.isEmpty else {
            return .empty
        }
        guard canBePacked else {
            // Encode each field separately with key
            return try encodedValues.mapAndJoin {
                try $0.encode(forKey: key)
            }
        }
        // Encode all fields into a variable-length container
        let keyData = WireType.len.encoded(with: key)
        let data = try encodedValues.mapAndJoin { try $0.encodeForUnkeyedContainer() }
        return keyData + data.count.variableLengthEncoded + data
    }

    func encodeForUnkeyedContainer() throws -> Data {
        throw DecodingError.notSupported("Nested unkeyed container not supported in unkeyed container", codingPath: codingPath)
    }

    private var canBePacked: Bool {
        encodedDataType != .len
    }
}
