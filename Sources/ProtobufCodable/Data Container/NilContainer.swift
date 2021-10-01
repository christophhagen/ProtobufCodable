import Foundation

/**
 An empty data container to encode `nil` values.

 The container uses the non-standard wire type `nilValue`, which signals to the decoder that a nil value is encoded for the property.
 - Note: Swift optionals are not supported by the protobuf specification, so any objects containing optionals will be incompatible with protobuf message definitions.
 */
struct NilContainer: BinaryEncodable {

    func binaryData() -> Data {
        .empty
    }

    var isDefaultValue: Bool {
        false
    }

    static let wireType: WireType = .nilValue
}
