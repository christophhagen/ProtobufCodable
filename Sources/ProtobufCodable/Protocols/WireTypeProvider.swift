import Foundation

/**
 A type which specifies a ``WireType`` for binary encoding.

 To understand more about wire types, see the [Protocol Buffer Message Structure](https://developers.google.com/protocol-buffers/docs/encoding#structure)
 */
protocol WireTypeProvider {

    /**
     The wire type used for encoding of the type.
     */
    static var wireType: WireType { get }
}

extension WireTypeProvider {

    /// The wire type of the value.
    var wireType: WireType {
        Self.wireType
    }
}
