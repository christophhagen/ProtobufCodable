import Foundation

final class ValueDecoder: CodingPathNode, SingleValueDecodingContainer {

    private let dataProvider: DecodingDataProvider

    private let includesLength: Bool

    init(path: [CodingKey], key: CodingKey?, info: [CodingUserInfoKey : Any], data: [FieldWithNilData], includesLength: Bool = false) {
        // Select the last data object
        // All previous values are discarded,
        // because the container should only ever contain a single value
        self.dataProvider = data.last?.field ?? .init(data: .empty)
        self.includesLength = includesLength
        super.init(path: path, key: key, info: info)
    }
    
    func decodeNil() -> Bool {
        dataProvider.isAtEnd
    }
    
    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        switch type {
        case let a as BinaryDecodable.Type:
            return try a.init(includingLengthFrom: dataProvider) as! T
        default:
            let provider: FieldWithNilData = (dataProvider, .empty)
            let decoder = TopLevelDecoder(path: codingPath, key: key, info: userInfo, data: [provider], includesLength: includesLength)
            return try T.init(from: decoder)
        }
    }
}
