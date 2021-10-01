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
            let decoder = DictionaryDecodingNode(path: [], key: nil, userInfo: [:], data: data)
            return try .init(from: decoder)
        } else {
            let decoder = TopLevelDecodingContainer(path: [], key: nil, info: [:], data: data)
            return try .init(from: decoder)
        }
    }
}
