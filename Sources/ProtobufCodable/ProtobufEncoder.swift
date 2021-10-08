import Foundation

/**
 An object that encodes instances of a data type as binary data.

 # Overview

 The example below shows how to encode an instance of a simple `GroceryProduct` type to binary data. The type adopts `Codable` so that it’s encodable as binary data using a `ProtobufEncoder` instance.
 ```swift
 struct GroceryProduct: Codable {
     var name: String
     var points: Int
     var description: String?
 }

 let pear = GroceryProduct(name: "Pear", points: 250, description: "A ripe pear.")

 let encoder = ProtobufEncoder()

 let data = try encoder.encode(pear)
 ```

 Use a ``ProtobufDecoder`` to reconstruct objects from the produced binary data.

 # Binary format

 The binary format is largely compatible with the [Google Protocol Buffer encoding](https://developers.google.com/protocol-buffers).

 In contrast to Protobuf, the binary encoder also supports string keys, optionals, a larger variety of integers as well as encoding and decoding of single values, arrays and dictionaries.

 */
public struct ProtobufEncoder {

    // MARK: Encoding options

    enum UserInfoKey: String {
        
        /// The user info key for omitting default values
        case omitDefaultValues = "omitDefaults"

        /// The user info key for hashing string keys to reduce binary size
        case hashStringKeys = "hashStrings"

        /// The user info key when enforcing the use of integer keys
        case requireIntegerCodingKeys = "forceIntegers"

        /// The user info key when enforcing the use of integer keys
        case requireProtobufCompatibility = "protobufCompatible"

        var userKey: CodingUserInfoKey {
            .init(rawValue: rawValue)!
        }
    }

    /**
     Prevent default values (like `zero`) from being written to binary data.
     
     Omitting defaults is default protobuf behaviour to reduce the binary size.
     - Warning: If you specify `true` when encoding objects with optional values,
     any default value will be decoded as `nil`.
     */
    public var omitDefaultValues = false

    /**
     Hash string keys of properties into integers to reduce binary size.
     - Warning: Hashing may introduce decoding errors when string keys map to the same hash.
     Carefully check wether objects can be successfully decoded before use.
     */
    var hashStringKeys = false

    /**
     Require that objects specify integer coding keys for each property to encode.

     Encoding non-compliant objects will result in a ``ProtobufEncodingError.missingIntegerCodingKey``
     */
    public var requireIntegerCodingKeys = false
    
    /**
     Fail if any components are present in the encoded object which are not compatible to Google Protobuf.
     
     Failures will result in a ``ProtobufEncodingError.notProtobufCompatible``
     */
    var requireProtobufCompatibility = false

    private var keys: [UserInfoKey : Bool] {
        [.omitDefaultValues : omitDefaultValues,
         .hashStringKeys : hashStringKeys,
         .requireIntegerCodingKeys : requireIntegerCodingKeys,
         .requireProtobufCompatibility : requireProtobufCompatibility]
    }

    /// The user info to pass to all nodes
    private var userInfo: [CodingUserInfoKey : Any] {
        keys.reduce(into: [:]) {
            $0[$1.key.userKey] = $1.value
        }
    }

    // MARK: Creating an encoder

    /**
     Create an encoder.

     An encoder is used to convert `Encodable` types to binary data.
     A single instance can be used to convert multiple objects.
     */
    public init() { }

    /**
     Convert an `Encodable` type to binary data.
     - Parameter value: The object to convert to data
     - Returns: The binary data
     - Throws: Errors of type `ProtobufEncodingError`
     */
    public func encode(_ value: Encodable) throws -> Data {
        if value is Dictionary<AnyHashable, Any> {
            let encoder = DictionaryEncoder(path: [], key: nil, info: userInfo)
            try value.encode(to: encoder)
            return try encoder.encodedData()
        } else {
            let encoder = TopLevelEncoder(path: [], key: nil, info: userInfo)
            try value.encode(to: encoder)
            return try encoder.encodedData()
        }
    }
}
