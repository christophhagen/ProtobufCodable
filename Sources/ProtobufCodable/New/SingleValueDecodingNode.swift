import Foundation

final class SingleValueDecodingNode: SingleValueDecodingContainer {
    
    let codingPath: [CodingKey]
    
    let dataProvider: DecodingDataProvider

    init(codingPath: [CodingKey], provider: DecodingDataProvider) {
        self.codingPath = codingPath
        self.dataProvider = provider
    }
    
    func decodeNil() -> Bool {
        dataProvider.isAtEnd
    }
    
    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        switch type {
        case let a as BinaryDecodable.Type:
            return try a.init(includingLengthFrom: dataProvider) as! T
            //return try a.init(from: dataProvider) as! T
        default:
            fatalError()
           // return try T.init(from: self)
        }
    }
}
