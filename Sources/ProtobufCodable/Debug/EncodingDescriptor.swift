import Foundation

struct EncodingDescriptor {
    
    /**
     Encode a value to binary data.
     - Parameter value: The value to encode
     - Returns: The encoded data
     - Throws: Errors of type `EncodingError`
     */
    public func encode(_ value: Encodable) throws -> Data {
        let encoder = DescribingEncoder(level: 0, codingPath: [], userInfo: [:])
        try value.encode(to: encoder)
        return .empty
    }
}

private class Node {

    let level: Int

    let codingPath: [CodingKey]

    let userInfo: [CodingUserInfoKey : Any]

    var nodeName: String {
        fatalError()
    }

    convenience init<Key>(node: Node, key: Key) where Key: CodingKey {
        self.init(level: node.level + 1, codingPath: node.codingPath + [key], userInfo: node.userInfo)
    }

    convenience init(node: Node) {
        self.init(level: node.level + 1, codingPath: node.codingPath, userInfo: node.userInfo)
    }

    init(level: Int, codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
        self.level = level
        self.codingPath = codingPath
        self.userInfo = userInfo
        print("(codingPath: \(codingPath.text), userInfo: \(userInfo))")
    }

    func print(_ message: String) {
        let indent = [String](repeating: "    ", count: level).joined()
        Swift.print("\(indent)\(nodeName)\(message)")
    }
}

private final class DescribingEncoder: Node, Encoder {

    override var nodeName: String {
        "Node"
    }

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        print(".container(keyedBy: \(type))")
        return KeyedEncodingContainer(DescribingKeyedEncoder<Key>(node: self))
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        print(".unkeyedContainer()")
        return DescribingUnkeyedEncoder(node: self)
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        print(".singleValueContainer()")
        return DescribingSingleValueEncoder.init(node: self)
    }
}

private final class DescribingSingleValueEncoder: Node, SingleValueEncodingContainer {

    override var nodeName: String {
        "Value"
    }

    func encodeNil() throws {
        print(".encodeNil()")
    }
    
    func encode(_ value: Bool) throws {
        print(".encode(\(value)) <- UInt64")
    }
    
    func encode(_ value: String) throws {
        print(".encode(\(value)) <- String")
    }
    
    func encode(_ value: Double) throws {
        print(".encode(\(value)) <- Double")
    }
    
    func encode(_ value: Float) throws {
        print(".encode(\(value)) <- Float")
    }
    
    func encode(_ value: Int) throws {
        print(".encode(\(value)) <- Int")
    }
    
    func encode(_ value: Int8) throws {
        print(".encode(\(value)) <- Int8")
    }
    
    func encode(_ value: Int16) throws {
        print(".encode(\(value)) <- Int16")
    }
    
    func encode(_ value: Int32) throws {
        print(".encode(\(value)) <- Int32")
    }
    
    func encode(_ value: Int64) throws {
        print(".encode(\(value)) <- Int64")
    }
    
    func encode(_ value: UInt) throws {
        print(".encode(\(value)) <- UInt")
    }
    
    func encode(_ value: UInt8) throws {
        print(".encode(\(value)) <- UInt8")
    }
    
    func encode(_ value: UInt16) throws {
        print(".encode(\(value)) <- UInt16")
    }
    
    func encode(_ value: UInt32) throws {
        print(".encode(\(value)) <- UInt32")
    }
    
    func encode(_ value: UInt64) throws {
        print(".encode(\(value)) <- UInt64")
    }
    
    func encode<T>(_ value: T) throws where T : Encodable {
        print(".encode<T>(\(value)) <- \(T.self)")
        let encoder = DescribingEncoder(level: level + 1, codingPath: codingPath, userInfo: [:])
        try value.encode(to: encoder)
    }
}

private final class DescribingUnkeyedEncoder: Node, UnkeyedEncodingContainer {

    override var nodeName: String {
        "Unkeyed"
    }

    let count: Int = 0

    func encodeNil() throws {
        print(".encodeNil()")
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        print(".nestedContainer(keyedBy: \(keyType)")
        return KeyedEncodingContainer(DescribingKeyedEncoder<NestedKey>(node: self))
    }
    
    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        print(".nestedUnkeyedContainer()")
        return DescribingUnkeyedEncoder(node: self)
    }
    
    func superEncoder() -> Encoder {
        print(".superEncoder()")
        return DescribingEncoder(node: self)
    }
    
    func encode(_ value: Bool) throws {
        print(".encode(\(value)) <- Bool")
    }
    
    func encode(_ value: String) throws {
        print(".encode(\(value)) <- String")
    }
    
    func encode(_ value: Double) throws {
        print(".encode(\(value)) <- Double")
    }
    
    func encode(_ value: Float) throws {
        print(".encode(\(value)) <- Float")
    }
    
    func encode(_ value: Int) throws {
        print(".encode(\(value)) <- Int")
    }
    
    func encode(_ value: Int8) throws {
        print(".encode(\(value)) <- Int8")
    }
    
    func encode(_ value: Int16) throws {
        print(".encode(\(value)) <- Int16")
    }
    
    func encode(_ value: Int32) throws {
        print(".encode(\(value)) <- Int32")
    }
    
    func encode(_ value: Int64) throws {
        print(".encode(\(value)) <- Int64")
    }
    
    func encode(_ value: UInt) throws {
        print(".encode(\(value)) <- UInt")
    }
    
    func encode(_ value: UInt8) throws {
        print(".encode(\(value)) <- UInt8")
    }
    
    func encode(_ value: UInt16) throws {
        print(".encode(\(value)) <- UInt16")
    }
    
    func encode(_ value: UInt32) throws {
        print(".encode(\(value)) <- UInt32")
    }
    
    func encode(_ value: UInt64) throws {
        print(".encode(\(value)) <- UInt64")
    }
    
    func encode<T>(_ value: T) throws where T : Encodable {
        print(".encode<T>(\(value)) <- \(T.self)")
        let encoder = DescribingEncoder(node: self)
        try value.encode(to: encoder)
    }
    
}

private final class DescribingKeyedEncoder<Key>: Node, KeyedEncodingContainerProtocol where Key: CodingKey {

    override var nodeName: String {
        "Keyed"
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        print(".nestedContainer(keyedBy: \(keyType), forKey: \(key.text))")
        return KeyedEncodingContainer(DescribingKeyedEncoder<NestedKey>(node: self, key: key))
    }
    
    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        print(".nestedUnkeyedContainer(forKey: \(key.text))")
        return DescribingUnkeyedEncoder(node: self, key: key)
    }
    
    func superEncoder() -> Encoder {
        print(".superEncoder()")
        return DescribingEncoder(node: self)
    }
    
    func superEncoder(forKey key: Key) -> Encoder {
        print(".superEncoder(forKey: \(key.text))")
        return DescribingEncoder(node: self, key: key)
    }
    
    func encodeNil(forKey key: Key) throws {
        print(".encodeNil(forKey: \(key.text))")
    }
    
    func encode(_ value: Bool, forKey key: Key) throws {
        print(".encode(\(value), forKey: \(key.text)) <- Bool")
    }
    
    func encode(_ value: String, forKey key: Key) throws {
        print(".encode(\(value), forKey: \(key.text)) <- String")
    }
    
    func encode(_ value: Double, forKey key: Key) throws {
        print(".encode(\(value), forKey: \(key.text)) <- Double")
    }
    
    func encode(_ value: Float, forKey key: Key) throws {
        print(".encode(\(value), forKey: \(key.text)) <- Float")
    }
    
    func encode(_ value: Int, forKey key: Key) throws {
        print(".encode(\(value), forKey: \(key.text)) <- Int")
    }
    
    func encode(_ value: Int8, forKey key: Key) throws {
        print(".encode(\(value), forKey: \(key.text)) <- Int8")
    }
    
    func encode(_ value: Int16, forKey key: Key) throws {
        print(".encode(\(value), forKey: \(key.text)) <- Int16")
    }
    
    func encode(_ value: Int32, forKey key: Key) throws {
        print(".encode(\(value), forKey: \(key.text)) <- Int32")
    }
    
    func encode(_ value: Int64, forKey key: Key) throws {
        print(".encode(\(value), forKey: \(key.text)) <- Int64")
    }
    
    func encode(_ value: UInt, forKey key: Key) throws {
        print(".encode(\(value), forKey: \(key.text)) <- UInt")
    }
    
    func encode(_ value: UInt8, forKey key: Key) throws {
        print("Keyed.encode(\(value), forKey: \(key.text)) <- UInt8")
    }
    
    func encode(_ value: UInt16, forKey key: Key) throws {
        print(".encode(\(value), forKey: \(key.text)) <- UInt16")
    }
    
    func encode(_ value: UInt32, forKey key: Key) throws {
        print(".encode(\(value), forKey: \(key.text)) <- UInt32")
    }
    
    func encode(_ value: UInt64, forKey key: Key) throws {
        print(".encode(\(value), forKey: \(key.text)) <- UInt64")
    }
    
    func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        print(".encode<T>(\(value), forKey: \(key.text)) <- \(T.self)")
        let encoder = DescribingEncoder(node: self, key: key)
        try value.encode(to: encoder)
    }
}

extension Array where Element == CodingKey {

    var text: String {
        "[" + map { $0.text }.joined(separator: ", ") + "]"
    }
}

extension CodingKey {

    var text: String {
        guard let intValue else {
            return "'\(stringValue)'"
        }
        return "'\(stringValue)' (\(intValue))"
    }
}
