import Foundation

extension Dictionary: DecodableContainer where Key: ProtobufMapKey, Value: Decodable {

    static var zero: Dictionary<Key, Value> {
        .init()
    }

    init(elements: [Data]) throws {
        self.init()
        for element in elements {
            let elementFields = try element.decodeKeyDataPairs()
            let key = try Self.decode(key: elementFields[1])
            let value = try Self.decode(value: elementFields[2])
            self[key] = value
        }
    }

    private static func decode(key data: [DataField]?) throws -> Key {
        guard let (wireType, keyData) = data?.last else {
            return .zero
        }
        guard wireType == Key.wireType else {
            throw CorruptedDataError(invalidType: wireType, for: "Map key")
        }
        return try .init(data: keyData)
    }

    private static func decode(value data: [DataField]?) throws -> Value {
        if let BaseType = Value.self as? DecodablePrimitive.Type {
            return try BaseType.init(elements: data) as! Value
        }

        let node = DecodingNode(data: data, codingPath: [], userInfo: [:])
        return try Value.init(from: node)
    }
}
