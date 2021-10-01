import Foundation

typealias KeyValueCodingKey = KeyValuePair<Int, Int>.CodingKeys

/**
 A struct to hold a key-value pair of a dictionary for encoding and decoding.

 Dictionaries (called "Maps" in the Protobuf definition) are encoded as key-value pairs,
 where the key is encoded with field `1` and the value with field `2`.
 - SeeAlso: [Language Guide (proto3): Maps](https://developers.google.com/protocol-buffers/docs/proto3#backwards_compatibility)
 */
struct KeyValuePair<Key, Value> {

    /**
     The integer fields corresponding to a key-value dictionary object within the Protobuf specification.
     */
    enum CodingKeys: Int, CodingKey {

        /// The field id for a dictionary key
        case key = 1

        /// The field id for a dictionary value
        case value = 2
    }

    /// The dictionary key
    let key: Key

    /// The dictionary value associated with the key
    let value: Value
}

extension KeyValuePair: Decodable where Key: Decodable, Value: Decodable {

}

extension KeyValuePair: Encodable where Key: Encodable, Value: Encodable {

}
