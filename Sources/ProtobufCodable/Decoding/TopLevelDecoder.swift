import Foundation

/**
 A class acting as a decoder, to provide different containers for decoding.
 */
final class TopLevelDecoder: AbstractDecodingNode, Decoder {

    private let data: Data

    private var didCallContainer = false

    init(data: Data, userInfo: [CodingUserInfoKey : Any]) {
        self.data = data
        super.init(codingPath: [], userInfo: userInfo)
    }

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        guard !didCallContainer else {
            throw DecodingError.corrupted("Multiple containers requested from decoder", codingPath: codingPath)
        }
        didCallContainer = true
        return KeyedDecodingContainer(try KeyedDecoder(data: [(type: .len, data: data)], codingPath: codingPath, userInfo: userInfo))
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        throw DecodingError.notSupported("Unkeyed containers at the top level are not supported", codingPath: [])
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        throw DecodingError.notSupported("Single value containers at the top level are not supported", codingPath: [])
    }
}
