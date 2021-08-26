import Foundation

extension Double: BinaryEncodable {
    
    public func binaryData() -> Data {
        hostIndependentBinaryData.swapped
    }
    
    /// The wire type of a double (64 bit)
    public var wireType: WireType {
        .length64
    }
}

extension Double: HostIndependentRepresentable {
    
    public var hostIndependentRepresentation: CFSwappedFloat64 {
        CFConvertDoubleHostToSwapped(self)
    }
    
    public init(fromHostIndependentRepresentation value: CFSwappedFloat64) {
        self = CFConvertDoubleSwappedToHost(value)
    }
}
