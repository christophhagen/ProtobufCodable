import Foundation

final class SingleValueDecodingNode: CodingPathNode, SingleValueDecodingContainer {

    let dataProvider: DecodingDataProvider

    init(path: [CodingKey], key: CodingKey?, data: [FieldWithNilData]) {
        // Select the last data object
        // All previous values are discarded,
        // because the container should only ever contain a single value
        self.dataProvider = data.last?.field ?? .init(data: .empty)
        super.init(path: path, key: key)
    }
    
    func decodeNil() -> Bool {
        dataProvider.isAtEnd
    }
    
    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        switch type {
        case let a as BinaryDecodable.Type:
            return try a.init(includingLengthFrom: dataProvider) as! T
        default:
            fatalError()
        }
    }
}
