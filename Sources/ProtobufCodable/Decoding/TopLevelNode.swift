import Foundation

final class TopLevelNode: Decoder {
    
    var codingPath: [CodingKey]
    
    var userInfo: [CodingUserInfoKey : Any]
    
    private var wrappedContainer: WrappedContainer?
    
    init(data: Data) {
        self.userInfo = [:]
        codingPath = []
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        throw DecodingError.dataCorrupted(.init(codingPath: codingPath, debugDescription: #function))
        // UnkeyedDecoder(decoder: self, data: data, parent: self)
    }
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        throw DecodingError.dataCorrupted(.init(codingPath: codingPath, debugDescription: #function))
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        throw DecodingError.dataCorrupted(.init(codingPath: codingPath, debugDescription: #function))
    }
    
}


protocol WrappedContainer {
    
}

final class ByteProvider: DecodingDataProvider {
    
    private let data: Data
    
    private var processedBytes: Int = 0
    
    init(data: Data) {
        self.data = data
    }
    
    var remainingByteCount: Int {
        data.count - processedBytes
    }
    
    func getNextBytes(_ count: Int) throws -> Data {
        guard count <= remainingByteCount else {
            throw ProtobufDecodingError.missingData
        }
        let newCount = processedBytes + count
        defer { processedBytes = newCount }
        return Data(data[processedBytes..<newCount])
    }
}
