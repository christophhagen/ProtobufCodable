import Foundation

extension Float: EncodablePrimitive {

    var protoTypeName: String {
        "float"
    }

    var encodedData: Data {
        .init(underlying: bitPattern.littleEndian)
    }
}

extension Float: DecodablePrimitive {

    static var wireType: WireType {
        .i32
    }

    init(data: Data) throws {
        guard data.count == MemoryLayout<UInt32>.size else {
            throw CorruptedDataError(invalidSize: data.count, for: "Float")
        }
        let value = UInt32(littleEndian: data.interpreted())
        self.init(bitPattern: value)
    }
}

// - MARK: Packable

extension Float: Packable {

}

