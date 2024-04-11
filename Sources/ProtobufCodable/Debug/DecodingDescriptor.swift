import Foundation

/*
struct DecodingDescriptor {
    
    func decode<T>(_ type: T, from data: Data) throws -> T {
        
    }
}

struct DescribingDecoder: Decoder {
    
    let codingPath: [CodingKey]
    
    let userInfo: [CodingUserInfoKey : Any]
    
    init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
        self.codingPath = codingPath
        self.userInfo = userInfo
        print("DescribingDecoder.init(codingPath: \(codingPath), userInfo: \(userInfo)")
    }
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        print("DescribingDecoder.unkeyedContainer()")
        return KeyedDecodingContainer(DescribingKeyedDecoder(codingPath: codingPath))
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        print("DescribingDecoder.unkeyedContainer()")
        return DescribingUnkeyedDecoder(codingPath: codingPath)
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        print("DescribingDecoder.singleValueContainer()")
        return DescribingSingleValueDecoder(codingPath: codingPath)
    }
}

struct DescribingSingleValueDecoder: SingleValueDecodingContainer {
    
    let codingPath: [CodingKey]
    
    init(codingPath: [CodingKey]) {
        self.codingPath = codingPath
        print("DescribingSingleValueDecoder.init(codingPath: \(codingPath)")
    }
    
    func decodeNil() -> Bool {
        <#code#>
    }
    
    func decode(_ type: Bool.Type) throws -> Bool {
        <#code#>
    }
    
    func decode(_ type: String.Type) throws -> String {
        <#code#>
    }
    
    func decode(_ type: Double.Type) throws -> Double {
        <#code#>
    }
    
    func decode(_ type: Float.Type) throws -> Float {
        <#code#>
    }
    
    func decode(_ type: Int.Type) throws -> Int {
        <#code#>
    }
    
    func decode(_ type: Int8.Type) throws -> Int8 {
        <#code#>
    }
    
    func decode(_ type: Int16.Type) throws -> Int16 {
        <#code#>
    }
    
    func decode(_ type: Int32.Type) throws -> Int32 {
        <#code#>
    }
    
    func decode(_ type: Int64.Type) throws -> Int64 {
        <#code#>
    }
    
    func decode(_ type: UInt.Type) throws -> UInt {
        <#code#>
    }
    
    func decode(_ type: UInt8.Type) throws -> UInt8 {
        <#code#>
    }
    
    func decode(_ type: UInt16.Type) throws -> UInt16 {
        <#code#>
    }
    
    func decode(_ type: UInt32.Type) throws -> UInt32 {
        <#code#>
    }
    
    func decode(_ type: UInt64.Type) throws -> UInt64 {
        <#code#>
    }
    
    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        <#code#>
    }
}

struct DescribingUnkeyedDecoder: UnkeyedDecodingContainer {
    
    let codingPath: [CodingKey]
    
    var count: Int? { nil }
    
    var isAtEnd: Bool { false }
    
    var currentIndex: Int = 0
    
    init(codingPath: [CodingKey]) {
        self.codingPath = codingPath
    }
    
    mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        KeyedDecodingContainer(DescribingKeyedDecoder(codingPath: codingPath))
    }
    
    mutating func nestedUnkeyedContainer() throws -> any UnkeyedDecodingContainer {
        <#code#>
    }
    
    mutating func superDecoder() throws -> any Decoder {
        <#code#>
    }
    
    mutating func decodeNil() throws -> Bool {
        <#code#>
    }
    
    mutating func decode(_ type: Bool.Type) throws -> Bool {
        <#code#>
    }
    
    mutating func decode(_ type: String.Type) throws -> String {
        <#code#>
    }
    
    mutating func decode(_ type: Double.Type) throws -> Double {
        <#code#>
    }
    
    mutating func decode(_ type: Float.Type) throws -> Float {
        <#code#>
    }
    
    mutating func decode(_ type: Int.Type) throws -> Int {
        <#code#>
    }
    
    mutating func decode(_ type: Int8.Type) throws -> Int8 {
        <#code#>
    }
    
    mutating func decode(_ type: Int16.Type) throws -> Int16 {
        <#code#>
    }
    
    mutating func decode(_ type: Int32.Type) throws -> Int32 {
        <#code#>
    }
    
    mutating func decode(_ type: Int64.Type) throws -> Int64 {
        <#code#>
    }
    
    mutating func decode(_ type: UInt.Type) throws -> UInt {
        <#code#>
    }
    
    mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
        <#code#>
    }
    
    mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
        <#code#>
    }
    
    mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
        <#code#>
    }
    
    mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
        <#code#>
    }
    
    mutating func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        <#code#>
    }
}

struct DescribingKeyedDecoder<Key>: KeyedDecodingContainerProtocol where Key: CodingKey {
    
    let codingPath: [CodingKey]
    
    init(codingPath: [CodingKey]) {
        self.codingPath = codingPath
        print("DecodingKeyedDecoder<\(Key.self)>.init(codingPath: \(codingPath))")
    }
    
    var allKeys: [Key] { [] }
    
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        print("DecodingKeyedDecoder<\(Key.self)>.nestedContainer(keyedBy: \(NestedKey.self), forKey: \(key)")
        return KeyedDecodingContainer(DescribingKeyedDecoder<NestedKey>(codingPath: codingPath + [key]))
    }
    
    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        print("DecodingKeyedDecoder<\(Key.self)>.nestedUnkeyedContainer(forKey: \(key)")
        return DescribingUnkeyedDecoder(codingPath: codingPath + [key])
    }
    
    func superDecoder() throws -> Decoder {
        <#code#>
    }
    
    func superDecoder(forKey key: Key) throws -> Decoder {
        <#code#>
    }
    
    func contains(_ key: Key) -> Bool {
        <#code#>
    }
    
    func decodeNil(forKey key: Key) throws -> Bool {
        <#code#>
    }
    
    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        <#code#>
    }
    
    func decode(_ type: String.Type, forKey key: Key) throws -> String {
        <#code#>
    }
    
    func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
        <#code#>
    }
    
    func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
        <#code#>
    }
    
    func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
        <#code#>
    }
    
    func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
        <#code#>
    }
    
    func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
        <#code#>
    }
    
    func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
        <#code#>
    }
    
    func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
        <#code#>
    }
    
    func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
        <#code#>
    }
    
    func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
        <#code#>
    }
    
    func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
        <#code#>
    }
    
    func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
        <#code#>
    }
    
    func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
        <#code#>
    }
    
    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        <#code#>
    }
}
*/
