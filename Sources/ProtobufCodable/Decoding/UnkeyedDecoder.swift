import Foundation
/*
class UnkeyedDecoder: DecodingNode, UnkeyedDecodingContainer {
    
    let decoder: Decoder
    
    var count: Int? = nil
    
    var isAtEnd: Bool {
        false
    }
    
    var currentIndex: Int = 0
    
    init(decoder: Decoder, data: Data, parent: DecodingTreeNode?) {
        self.decoder = decoder
        super.init(data: data, parent: parent)
    }
    
    // MARK: Encoding
    
    func decodeNil() throws -> Bool {
        false
    }
    
    func decode(_ type: Bool.Type) throws -> Bool {
        throw DecodingError.valueNotFound(type, .init(codingPath: codingPath, debugDescription: ""))
    }
    
    func decode(_ type: String.Type) throws -> String {
        throw DecodingError.valueNotFound(type, .init(codingPath: codingPath, debugDescription: ""))
    }

    func decode(_ type: Double.Type) throws -> Double {
        throw DecodingError.valueNotFound(type, .init(codingPath: codingPath, debugDescription: ""))
    }

    func decode(_ type: Float.Type) throws -> Float {
        throw DecodingError.valueNotFound(type, .init(codingPath: codingPath, debugDescription: ""))
    }

    func decode(_ type: Int.Type) throws -> Int {
        throw DecodingError.valueNotFound(type, .init(codingPath: codingPath, debugDescription: ""))
    }

    func decode(_ type: Int8.Type) throws -> Int8 {
        throw DecodingError.valueNotFound(type, .init(codingPath: codingPath, debugDescription: ""))
    }

    func decode(_ type: Int16.Type) throws -> Int16 {
        throw DecodingError.valueNotFound(type, .init(codingPath: codingPath, debugDescription: ""))
    }

    func decode(_ type: Int32.Type) throws -> Int32 {
        throw DecodingError.valueNotFound(type, .init(codingPath: codingPath, debugDescription: ""))
    }

    func decode(_ type: Int64.Type) throws -> Int64 {
        throw DecodingError.valueNotFound(type, .init(codingPath: codingPath, debugDescription: ""))
    }

    func decode(_ type: UInt.Type) throws -> UInt {
        throw DecodingError.valueNotFound(type, .init(codingPath: codingPath, debugDescription: ""))
    }

    func decode(_ type: UInt8.Type) throws -> UInt8 {
        throw DecodingError.valueNotFound(type, .init(codingPath: codingPath, debugDescription: ""))
    }

    func decode(_ type: UInt16.Type) throws -> UInt16 {
        throw DecodingError.valueNotFound(type, .init(codingPath: codingPath, debugDescription: ""))
    }

    func decode(_ type: UInt32.Type) throws -> UInt32 {
        throw DecodingError.valueNotFound(type, .init(codingPath: codingPath, debugDescription: ""))
    }

    func decode(_ type: UInt64.Type) throws -> UInt64 {
        throw DecodingError.valueNotFound(type, .init(codingPath: codingPath, debugDescription: ""))
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        throw DecodingError.valueNotFound(type, .init(codingPath: codingPath, debugDescription: ""))
    }
    
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        throw DecodingError.dataCorrupted(.init(codingPath: codingPath, debugDescription: #function))
    }
    
    func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        UnkeyedDecoder(decoder: decoder, data: data, parent: self)
    }
    
    func superDecoder() throws -> Decoder {
        decoder
    }
}
*/
