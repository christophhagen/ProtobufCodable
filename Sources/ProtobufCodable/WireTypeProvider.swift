import Foundation

public protocol WireTypeProvider {
    
    /**
     The wire type used for encoding of the type.
     */
    static var wireType: WireType { get }
}

extension WireTypeProvider {

    var wireType: WireType {
        Self.wireType
    }
}

public protocol FixedLengthWireType: WireTypeProvider {
    
    static var fixedLengthWireType: WireType { get }
}

extension FixedLengthWireType {

    var fixedLengthWireType: WireType {
        Self.fixedLengthWireType
    }
}
