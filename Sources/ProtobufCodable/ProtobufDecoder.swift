import Foundation

/**
 A type to decode objects from binary data produced by ``ProtobufEncoder``.

 # Overview

 The example below shows how to decode an instance of a simple `GroceryProduct` type from binary data. The type adopts `Codable` so that it’s decodable using a `ProtobufDecoder` instance.
 ```swift
 struct GroceryProduct: Codable {
     var name: String
     var points: Int
     var description: String?
 }

 let source = GroceryProduct(
     name: "Durian",
     points: 600,
     description: "A fruit with a distinctive scent.")
 
 let binaryData = ProtobufEncoder().encode(source)

 let decoder = ProtobufDecoder()
 let product = try decoder.decode(GroceryProduct.self, from: binaryData)

 print(product.name) // Prints "Durian"
 ```
 */
public struct ProtobufDecoder {

    /**
     Creates a new, reusable binary decoder.
     */
    public init() { }
    
    // MARK: Options
    
    static let intOverflowKey = CodingUserInfoKey(rawValue: "integerOverflow")!
    
    enum IntegerOverflowDecodingStrategy {
        
        /// Throw an error, if a varint is too large/small to fit in the type
        case fail
        
        /// If a varint is too large/too small, use `min`/`max` values of the type
        case clamp
        
        /// If a varint is too large/small, overflow the type
        case overflow
    }
    
    var integerOverflowDecodingStrategy: IntegerOverflowDecodingStrategy = .fail
    
    var userInfo: [CodingUserInfoKey: Any] {
        [Self.intOverflowKey : integerOverflowDecodingStrategy]
    }
    
    // MARK: Decoding

    /**
     Returns a value of the type you specify, decoded from binary data.


     - Parameter type: The type of the value to decode from the supplied data.
     - Parameter data: The binary data to decode.
     - Returns: A value of the specified type, if the decoder can parse the data.
     - Throws: Errors of type `ProtobufDecodingError`
     */
    public func decode<T>(_ type: T.Type = T.self, from data: Data) throws -> T where T: Decodable {
        let data: [FieldWithNilData] = [(.init(data: data), nil)]
        if type is AnyDictionary.Type {
            let decoder = DictionaryDecoder(path: [], key: nil, info: userInfo, data: data)
            return try .init(from: decoder)
        } else {
            let decoder = TopLevelDecoder(path: [], key: nil, info: userInfo, data: data)
            return try .init(from: decoder)
        }
    }

    /**
     Decode a value of a type from binary data.

     This function is a convenience wrapper to decode, and is equivalent to:
     ```swift
        let decoder = ProtobufDecoder()
        let value = try decoder.decode(MyType.self, from: data)
     ```
     Uses the default decoding options.
     - Parameter type: The type of the value to decode from the supplied data.
     - Parameter data: The binary data to decode.
     - Returns: A value of the specified type, if the decoder can parse the data.
     - Throws: Errors of type `ProtobufDecodingError`
     */
    static func decode<T>(_ type: T.Type = T.self, from data: Data) throws -> T where T: Decodable {
        let decoder = ProtobufDecoder()
        return try decoder.decode(from: data)
    }
}
