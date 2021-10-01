import Foundation

/**
 A container to provide individual bytes while decoding.

 A decoding container is used to provide chunks of data while traversing a stream of binary data,
 and to extract components such as keys and fields.
 */
final class DecodingDataProvider {

    /// The complete data contained in the node.
    private let data: [UInt8]

    /// The number of bytes already read from the container.
    private(set) var processedBytes: Int = 0

    /**
     Create a data provider from a chunk of encoded data.
     - Parameter data: The data to wrap.
     */
    init(data: Data) {
        self.data = data.bytes
    }

    /// An container without any data to provide
    static var empty: DecodingDataProvider {
        .init(data: .empty)
    }

    /// The number of bytes still readable from the container
    var remainingByteCount: Int {
        data.count - processedBytes
    }

    /**
     Get a  number of bytes from the container.
     - Parameter count: The number of bytes to obtain.
     - Returns: The requested number of bytes.
     - Throws: `ProtobufDecodingError.missingData`, if not enough bytes are available.
     */
    func getNextBytes(_ count: Int) throws -> Data {
        guard count <= remainingByteCount else {
            throw ProtobufDecodingError.missingData
        }
        let newCount = processedBytes + count
        defer { processedBytes = newCount }
        return Data(data[processedBytes..<newCount])
    }

    /**
     Get a single byte from the container.
     - Returns: The requested byte.
     - Throws: `ProtobufDecodingError.missingData`, if no more bytes are available.
     */
    func getNextByte() throws -> UInt8 {
        guard remainingByteCount > 0 else {
            throw ProtobufDecodingError.missingData
        }
        defer { processedBytes += 1 }
        return data[processedBytes]
    }

    /**
     Get all bytes not yet processed from the container.
     - Returns: The remaining bytes.
     */
    func getRemainingBytes() -> Data {
        defer { processedBytes = data.count }
        return Data(data[processedBytes...])
    }

    /// Indicates that the container has no more bytes to provide
    var isAtEnd: Bool {
        remainingByteCount == 0
    }

    /**
     Extract the data of an integer encoded with variable-length encoding.

     Variable-length encoding uses the first (MSB) bit of each byte to indicate that another byte follows. Varints have a maximum length of 10 bytes.
     - SeeAlso: [Protocol Buffer Encoding: Base 128 Varints](https://developers.google.com/protocol-buffers/docs/encoding#varints)
     - Throws: `ProtobufDecodingError.missingData`, `ProtobufDecodingError.invalidVarintEncoding`
     - Returns: The bytes needed to decode a variable-length integer.
     */
    func extractVarint() throws -> Data {
        for i in 0..<10 {
            let index = processedBytes + i
            guard index < data.count else {
                throw ProtobufDecodingError.missingData
            }
            guard data[index] & 0x80 > 0 else {
                defer { processedBytes = index + 1 }
                return Data(data[processedBytes...index])
            }
        }
        throw ProtobufDecodingError.invalidVarintEncoding
    }

    /**
     Get a keyed field from the container.

     A keyed field is determined by its tag, which contains the field (integer or string), plus a wire type to indicate the length of the corresponding data.
     - Returns: The tag of the keyed field (key and wire type), and the corresponding data.
     - Throws:
     */
    func getKeyedField() throws -> (Tag, Data) {
        let tag = try Tag(from: self)
        let data: Data
        // Most wire types have a fixed length
        if let length = tag.valueLength {
            data = try getNextBytes(length)
        }else if tag.wireType == .lengthDelimited {
            data = try getLengthEncodedField()
        } else {
            // Only choice left is varint
            data = try extractVarint()
        }
        return (tag, data)
    }

    /**
     Get the data for a field with a length prepended to it.
     - Throws: `ProtobufDecodingError.missingData`
     */
    func getLengthEncodedField() throws -> Data {
        let length = try Int(from: self)
        return try getNextBytes(length)
    }

    func printRemainingBytes() {
        print("Remaining: \(data[processedBytes...])")
    }

    func printAllBytes() {
        print("All: \(data)")
    }
}

extension DecodingDataProvider: CustomStringConvertible {

    /// A description of the data container
    var description: String {
        "\(processedBytes)/\(data.count) bytes: \(data[processedBytes...])"
    }
}
