import Foundation

extension Dictionary: EncodableContainer where Key: ProtobufMapKey, Value: Encodable {

    func encodeForUnkeyedContainer() throws -> Data {
        try encodedElements().map {
            $0.encodeForUnkeyedContainer()
        }.joinedData
    }

    func encode(forKey key: Int) throws -> Data {
        try encodedElements().map {
            $0.encode(forKey: key)
        }.joinedData
    }

    private func encodedElements() throws -> [Data] {
        try map { key, value in
            let node = try encode(value)
            return try key.encode(forKey: 1) + node.encode(forKey: 2)
        }
    }

    private func encode<T>(_ value: T) throws -> EncodableContainer where T: Encodable {
        if T.self is EncodablePrimitive.Type, let base = value as? EncodablePrimitive {
            return base
        }
        // All non-primitive types are of type `len`
        let encoder = EncodingNode(codingPath: [], userInfo: [:])
        try value.encode(to: encoder)
        return encoder
    }
}
