import Foundation

/**
 An encoder to convert `Codable` objects to protobuf binary data.

 The encoder provides only limited compatibility with Google's Protocol Buffers.

 Encoding unsupported data types causes `ProtobufEncodingError` errors.

 Construct an encoder when converting instances to binary data, and feed the message(s) into it:

 ```swift
 let message: Message = ...

 let encoder = ProtobufEncoder()
 let data = try encoder.encode(message)
 ```

 - Note: An ecoder can be used to encode multiple messages.
 */
public struct ProtobufEncoder {
    
    /// The user info key for the ``sortKeysDuringEncoding`` option.
    public static let userInfoSortKey: CodingUserInfoKey = .init(rawValue: "sortByKey")!

    /**
     Sort keyed data in the binary representation.

     Enabling this option causes all data in keyed containers (e.g. `Dictionary`, `Struct`) to be sorted by their keys before encoding.
     This option can enable deterministic encoding where the binary output is consistent across multiple invocations.

     - Warning: Output will not be deterministic when using `Set`, or `Dictionary<Key, Value>` where `Key` is not `String` or `Int`.

     Enabling this option introduces computational overhead due to sorting, which can become significant when dealing with many entries.

     This option has no impact on decoding using `BinaryDecoder`.

     Enabling this option will add the `CodingUserInfoKey(rawValue: "sortByKey")` to the `userInfo` dictionary.
     This key is also available as ``userInfoSortKey``

     - Note: The default value for this option is `false`.
     */
    public var sortKeysDuringEncoding: Bool {
        get {
            userInfo[ProtobufEncoder.userInfoSortKey] as? Bool ?? false
        }
        set {
            userInfo[ProtobufEncoder.userInfoSortKey] = newValue
        }
    }

    /**
     Any contextual information set by the user for encoding.

     This dictionary is passed to all containers during the encoding process.

     Contains also keys for any custom options set for the encoder.
     See `sortKeysDuringEncoding`.
     */
    public var userInfo = [CodingUserInfoKey : Any]()

    /**
     Create a new binary encoder.
     - Note: An encoder can be used to encode multiple messages.
     */
    public init() {

    }

    /**
     Encode a value to binary data.
     - Parameter value: The value to encode
     - Returns: The encoded data
     - Throws: Errors of type `EncodingError` or `ProtobufEncodingError`
     */
    public func encode<T>(_ value: T) throws -> Data where T: Encodable {
        let root = TopLevelEncoder(userInfo: userInfo)
        try value.encode(to: root)
        return try root.containedData()
    }

    /**
     Encode a single value to binary data using a default encoder.
     - Parameter value: The value to encode
     - Returns: The encoded data
     - Throws: Errors of type `EncodingError` or `ProtobufEncodingError`
     */
    public static func encode<T>(_ value: T) throws -> Data where T: Encodable {
        try ProtobufEncoder().encode(value)
    }

    func getProtobufDefinition<T>(_ value: T) throws -> String where T: Encodable {
        throw EncodingError.invalidValue(0, .init(codingPath: [], debugDescription: "Not implemented"))
        //let root = try ProtoNode(encoding: "\(type(of: value))", path: [], info: userInfo)
        //    .encoding(value)
        //return try "syntax = \"proto3\";\n\n" + root.protobufDefinition()
    }
}
