import Foundation

final class OneOfEncoder: AbstractEncodingNode, Encoder {

    private var encoded: EncodableContainerAndKeyProvider?

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        let container = OneOfKeyedEncoder<Key>(codingPath: codingPath, userInfo: userInfo)
        self.encoded = container
        return .init(container)
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        UnsupportedUnkeyedEncoder("Unkeyed container is not supported for OneOf")
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        UnsupportedValueEncoder("Single value container is not supported for OneOf")
    }

    var encodedValue: EncodableContainer? {
        encoded?.encodedValue
    }

    var encodedKey: CodingKey? {
        encoded?.key
    }
}

extension OneOfEncoder: EncodableContainer {

    func encodeForUnkeyedContainer() throws -> Data {
        throw EncodingError.unsupported(self, "OneOf is not supported in unkeyed containers", codingPath: codingPath)
    }

    func encode(forKey key: Int) throws -> Data {
        guard let encodedValue else {
            throw EncodingError.invalidValue(0, .init(codingPath: codingPath, debugDescription: "Missing encoded value for OneOf"))
        }
        return try encodedValue.encode(forKey: key)
    }
}

private protocol EncodableContainerAndKeyProvider {

    var encodedValue: EncodableContainer? { get }

    var key: CodingKey? { get }
}

private final class OneOfKeyedEncoder<Key>: AbstractEncodingNode, KeyedEncodingContainerProtocol where Key: CodingKey {

    private var encoded: EncodableContainerProvider?

    var key: CodingKey?

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let container = OneOfNestedKeyedEncoder<NestedKey>(codingPath: codingPath, userInfo: userInfo)
        self.encoded = container
        self.key = key
        return .init(container)
    }
    
    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        UnsupportedUnkeyedEncoder("OneOf doesn't support nestedUnkeyedContainer(forKey:)")
    }
    
    func superEncoder() -> any Encoder {
        UnsupportedSuperEncoder("OneOf doesn't support superEncoder()")
    }
    
    func superEncoder(forKey key: Key) -> any Encoder {
        UnsupportedSuperEncoder("OneOf doesn't support superEncoder(forKey:)")
    }

    func encodeNil(forKey key: Key) throws {
        throw EncodingError.unsupported(key, "OneOf doesn't support encodeNil(forKey:)", codingPath: codingPath)
    }

    func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        throw EncodingError.unsupported(key, "OneOf doesn't support encode<T>(_:forKey:)", codingPath: codingPath)
    }
}

extension OneOfKeyedEncoder: EncodableContainerAndKeyProvider {

    var encodedValue: EncodableContainer? {
        encoded?.encodedValue
    }
}

private protocol EncodableContainerProvider {

    var encodedValue: EncodableContainer? { get }
}

private final class OneOfNestedKeyedEncoder<Key>: AbstractEncodingNode, KeyedEncodingContainerProtocol where Key: CodingKey {

    var encodedValue: EncodableContainer?

    func encodeNil(forKey key: Key) throws {
        throw EncodingError.unsupported(key, "OneOf doesn't support encodeNil(forKey:)", codingPath: codingPath)
    }
    
    func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        guard key.stringValue == "_0" else {
            throw EncodingError.unsupported(value, "Unexpected key '\(key.stringValue)' in OneOf", codingPath: codingPath)
        }
        guard encodedValue == nil else {
            throw EncodingError.invalidValue(value, .init(codingPath: codingPath, debugDescription: "OneOf: Multiple calls to encode<T>()"))
        }
        if let unsupported = value as? UnsupportedEncodable {
            throw EncodingError.unsupported(unsupported, "Unsupported value of type \(T.self) for key '\(key.stringValue)'", codingPath: codingPath)
        }
        if T.self is EncodablePrimitive.Type, let base = value as? EncodablePrimitive {
            self.encodedValue = base
            // Always encode default values
            return
        }
        // Everything allowed except `map` fields and `repeated` fields
        if T.self is AnyDictionary.Type {
            throw EncodingError.unsupported(value, "OneOf doesn't support dictionaries", codingPath: codingPath)
        }
        if T.self is any Sequence.Type {
            throw EncodingError.unsupported(value, "OneOf doesn't support repeated fields", codingPath: codingPath)
        }
        let encoder = EncodingNode(codingPath: codingPath, userInfo: userInfo)
        try value.encode(to: encoder)
        self.encodedValue = encoder
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        .init(UnsupportedKeyedEncoder("OneOf doesn't support nestedContainer<NestedKey>(keyedBy:forKey:)"))
    }
    
    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        UnsupportedUnkeyedEncoder("OneOf doesn't support nestedUnkeyedContainer(forKey:)")
    }

    func superEncoder() -> any Encoder {
        UnsupportedSuperEncoder("OneOf doesn't support superEncoder()")
    }

    func superEncoder(forKey key: Key) -> any Encoder {
        UnsupportedSuperEncoder("OneOf doesn't support superEncoder(forKey:)")
    }
}

extension OneOfNestedKeyedEncoder: EncodableContainerProvider {

}
