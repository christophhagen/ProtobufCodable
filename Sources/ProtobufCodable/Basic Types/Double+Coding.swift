import Foundation

extension Double: BinaryEncodable {
    
    func binaryData() -> Data {
        hostIndependentBinaryData.swapped
    }
}

extension Double: WireTypeProvider {
    
    /// The wire type of a double (64 bit)
    public static var wireType: WireType {
        .length64
    }
}

extension Double: BinaryDecodable {

    /**
     Decode a double from a data container.

     - Parameter byteProvider: The container with the encoded data.
     - Throws: `ProtobufDecodingError.missingData`, if not enough bytes are available.
     */
    init(from byteProvider: DecodingDataProvider) throws {
        let data = try byteProvider.getNextBytes(Self.binaryDataSize).swapped
        try self.init(hostIndependentBinaryData: data)
    }
}

extension Double: HostIndependentRepresentable {

    /// The double converted to little-endian
    var hostIndependentRepresentation: CFSwappedFloat64 {
        CFConvertDoubleHostToSwapped(self)
    }

    /**
     Create a double from a little-endian float64.
     - Parameter value: The host-independent representation.
     */
    init(fromHostIndependentRepresentation value: CFSwappedFloat64) {
        self = CFConvertDoubleSwappedToHost(value)
    }

    /// Create an empty host-indepentent float64
    static var empty: CFSwappedFloat64 { .init() }
}
