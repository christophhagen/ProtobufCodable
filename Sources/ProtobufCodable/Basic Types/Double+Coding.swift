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

extension Double: BinaryDecodable {
    
    public init(from byteProvider: DecodingDataProvider) throws {
        let data = try byteProvider.getNextBytes(Self.binaryDataSize).swapped
        try self.init(hostIndependentBinaryData: data)
    }
}


extension Double: HostIndependentRepresentable {
    
    public var hostIndependentRepresentation: CFSwappedFloat64 {
        CFConvertDoubleHostToSwapped(self)
    }
    
    public init(fromHostIndependentRepresentation value: CFSwappedFloat64) {
        self = CFConvertDoubleSwappedToHost(value)
    }
    
    public static var empty: CFSwappedFloat64 { .init() }
}
