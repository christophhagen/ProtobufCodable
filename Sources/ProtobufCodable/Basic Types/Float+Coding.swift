import Foundation

extension Float: BinaryEncodable {
    
    public func binaryData() -> Data {
        hostIndependentBinaryData.swapped
    }
    
    public var wireType: WireType {
        .length32
    }
}

extension Float: HostIndependentRepresentable {
    
    public var hostIndependentRepresentation: CFSwappedFloat32 {
        CFConvertFloatHostToSwapped(self)
    }
    
    public init(fromHostIndependentRepresentation value: CFSwappedFloat32) {
        self = CFConvertFloatSwappedToHost(value)
    }
}
