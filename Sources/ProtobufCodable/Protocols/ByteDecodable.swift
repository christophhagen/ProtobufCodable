import Foundation

/**
 A type which can be decoded from a data stream.
 */
protocol ByteDecodable {

    /**
     Create a value from a container with encoded data.
     - Parameter byteProvider: The container with encoded data
     - Throws: Errors of type ``ProtobufDecodingError``
     */
    init(from byteProvider: DecodingDataProvider) throws
}
