import Foundation

/// An integer type which can be forced to use a fixed-length encoding instead of variable-length encoding.
public protocol FixedWidthCompatible {

    /// The wire type of the type, which has a constant length
    static var fixedLengthWireType: WireType { get }
}

extension FixedWidthCompatible {

    /// The wire type of the value, which has a constant length
    var fixedLengthWireType: WireType {
        Self.fixedLengthWireType
    }
}
