import Foundation

public protocol ByteDecodable {

    init(from byteProvider: DecodingDataProvider) throws
}
/**
 A protocol adopted by all types which can be converted to binary data.
 */
public protocol BinaryDecodable: ByteDecodable, WireTypeProvider, Decodable {
    
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

public extension BinaryEncodable where Self: AdditiveArithmetic {

    /**
     The default value for an integer (`zero`)
     */
    static var defaultValue: Self { .zero }
}
