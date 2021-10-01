import Foundation

/**
 A protocol adopted by all types which can be decoded from binary data.
 */
protocol BinaryDecodable: ByteDecodable, WireTypeProvider, Decodable {

    static var defaultValue: Self { get }
}

extension BinaryDecodable {

    init(includingLengthFrom byteProvider: DecodingDataProvider) throws {
        guard Self.wireType == .lengthDelimited else {
            try self.init(from: byteProvider)
            return
        }
        let length = try Int.init(from: byteProvider)
        let data = try byteProvider.getNextBytes(length)
        try self.init(encodedData: data)
    }

    init(encodedData data: Data) throws {
        try self.init(from: DecodingDataProvider(data: data))
    }
}

extension BinaryEncodable where Self: AdditiveArithmetic {

    /**
     The default value for an integer (`zero`)
     */
    static var defaultValue: Self { .zero }
}
