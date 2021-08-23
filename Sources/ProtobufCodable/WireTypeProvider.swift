import Foundation

public protocol WireTypeProvider {
    
    var wireType: WireType { get }
}

public protocol FixedLengthWireType: WireTypeProvider {
    
    var fixedLengthWireType: WireType { get }
}
