import Foundation

extension Float: BinaryEncodable {
    
    public func binaryData() -> Data {
        hostIndependentBinaryData.swapped
    }
    
    public static var wireType: WireType {
        .length32
    }
}

extension Float: BinaryDecodable {
    
    public init(from byteProvider: DecodingDataProvider) throws {
        let data = try byteProvider.getNextBytes(Self.binaryDataSize).swapped
        try self.init(hostIndependentBinaryData: data)
    }
}

extension Float: HostIndependentRepresentable {
    
    public var hostIndependentRepresentation: CFSwappedFloat32 {
        CFConvertFloatHostToSwapped(self)
    }
    
    public init(fromHostIndependentRepresentation value: CFSwappedFloat32) {
        self = CFConvertFloatSwappedToHost(value)
    }
    
    public static var empty: CFSwappedFloat32 { .init() }
}
