import Foundation

/**
 A class acting as a decoder, to provide different containers for decoding.
 */
final class DecodingNode: AbstractDecodingNode, Decoder {

    private let data: [DataField]?

    private var didCallContainer = false

    init(data: [DataField]?, codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
        self.data = data
        super.init(codingPath: codingPath, userInfo: userInfo)
    }
    
    private func registerContainer() throws {
        guard !didCallContainer else {
            throw DecodingError.corrupted("Multiple containers requested from decoder", codingPath: codingPath)
        }
        didCallContainer = true
    }
    
    private func getElements() throws -> [DataField]? {
        try registerContainer()
        return data
    }
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        let data = try getElements()
        let container = try KeyedDecoder<Key>(data: data, codingPath: codingPath, userInfo: userInfo)
        return .init(container)
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        let data = try getElements()
        return try UnkeyedDecoder(data: data, codingPath: codingPath, userInfo: userInfo)
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        let data = try getElements()
        return EnumDecoder(elements: data, codingPath: codingPath, userInfo: userInfo)
    }
}
