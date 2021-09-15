import Foundation

/**
 A protocol adopted by all types which can be converted to binary data.
 */
public protocol BinaryDecodable: WireTypeProvider, Decodable {
    
    init(from byteProvider: DecodingDataProvider) throws
}
