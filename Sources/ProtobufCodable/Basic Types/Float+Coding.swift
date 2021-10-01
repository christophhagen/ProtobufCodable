import Foundation

extension Float: BinaryEncodable {

    /**
     Convert the float to little-endian binary data.
     - Returns: The binary data
     */
    func binaryData() -> Data {
        hostIndependentBinaryData.swapped
    }
}

extension Float: WireTypeProvider {

    /// The wire type of a float (`length32`)
    public static var wireType: WireType {
        .length32
    }
}

extension Float: BinaryDecodable {

    /**
     Decode a float from a data container.

     - Parameter byteProvider: The container with the encoded data.
     - Throws: `ProtobufDecodingError.missingData`, if not enough bytes are available.
     */
    init(from byteProvider: DecodingDataProvider) throws {
        let data = try byteProvider.getNextBytes(Self.binaryDataSize).swapped
        try self.init(hostIndependentBinaryData: data)
    }
}

extension Float: HostIndependentRepresentable {

    /// The float converted to little-endian
    var hostIndependentRepresentation: CFSwappedFloat32 {
        CFConvertFloatHostToSwapped(self)
    }

    /**
     Create a float from a little-endian float32.
     - Parameter value: The host-independent representation.
     */
    init(fromHostIndependentRepresentation value: CFSwappedFloat32) {
        self = CFConvertFloatSwappedToHost(value)
    }

    /// Create an empty host-indepentent float32
    static var empty: CFSwappedFloat32 { .init() }
}
