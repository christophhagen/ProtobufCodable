import Foundation

/**
 An abstract node specifying a coding path within a codable container.
 */
class CodingPathNode {

    /**
     The key associated with the current path.

     If the key is nil, then the node is at the top level.
     */
    let key: CodingKey?

    /**
     The path taken to reach the node within the value to encode/decode.
     */
    let codingPath: [CodingKey]
    
    /**
     The user info for encoding and decoding
     */
    let userInfo: [CodingUserInfoKey: Any]

    /**
     Create a new node.
     - Parameter path: The coding path to the node, including the node's key.
     - Parameter key: The key associated with the node.
     */
    init(path: [CodingKey], key: CodingKey?, info: [CodingUserInfoKey: Any]) {
        self.codingPath = path
        self.key = key
        self.userInfo = info
    }

    private func isSet(_ option: ProtobufEncoder.UserInfoKey) -> Bool {
        userInfo[option.userKey] as? Bool ?? false
    }

    /**
     Prevent default values (like `zero`) from being written to binary data.

     Omitting defaults is default protobuf behaviour to reduce the binary size.
     - Warning: If you specify `true` when encoding objects with optional values,
     any default value will be decoded as `nil`.
     */
    var omitDefaultValues: Bool {
        isSet(.omitDefaultValues)
    }

    /**
     Hash string keys of properties into integers to reduce binary size.
     - Warning: Hashing may introduce decoding errors when string keys map to the same hash.
     Carefully check wether objects can be successfully decoded before use.
     */
    var hashStringKeys: Bool {
        isSet(.hashStringKeys)
    }

    /**
     Require that objects specify integer coding keys for each property to encode.

     Encoding non-compliant objects will result in a ``ProtobufEncodingError.missingIntegerCodingKey``
     */
    var requireIntegerCodingKeys: Bool {
        isSet(.requireIntegerCodingKeys)
    }

    /**
     Fail if any components are present in the encoded object which are not compatible to Google Protobuf.

     Failures will result in a ``ProtobufEncodingError.notProtobufCompatible``
     */
    var requireProtobufCompatibility: Bool {
        isSet(.requireProtobufCompatibility)
    }

}
