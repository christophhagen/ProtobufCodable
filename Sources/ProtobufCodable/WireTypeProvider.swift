import Foundation

public protocol WireTypeProvider {
    
    /**
     The wire type used for encoding of the type.
     */
    var wireType: WireType { get }
}

public protocol FixedLengthWireType: WireTypeProvider {
    
    var fixedLengthWireType: WireType { get }
}
