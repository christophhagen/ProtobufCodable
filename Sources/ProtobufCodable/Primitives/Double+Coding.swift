import Foundation

extension Double: EncodablePrimitive {

    var protoTypeName: String {
        "double"
    }

    var encodedData: Data {
        .init(underlying: bitPattern.littleEndian)
    }

}

extension Double: DecodablePrimitive {

    static var wireType: WireType {
        .i64
    }

    init(data: Data) throws {
        guard data.count == MemoryLayout<UInt64>.size else {
            throw CorruptedDataError(invalidSize: data.count, for: "Double")
        }
        let value = UInt64(littleEndian: data.interpreted())
        self.init(bitPattern: value)
    }
}

// - MARK: Packable

extension Double: Packable {

}

