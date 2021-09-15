import Foundation

final class SingleValueDecodingNode: SingleValueDecodingContainer {
    
    var codingPath: [CodingKey]
    
    let dataProvider: DecodingDataProvider
    
    init(codingPath: [CodingKey], data: Data) {
        self.codingPath = codingPath
        self.dataProvider = ByteProvider(data: data)
    }
    
    func decodeNil() -> Bool {
        dataProvider.isAtEnd
    }
    
    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        switch type {
//        case is Float.Type: return try Float(from: dataProvider) as! T
//        case is Double.Type: return try Double(from: dataProvider) as! T
//        case is Bool.Type: return try Bool(from: dataProvider) as! T
//        case is String.Type: return try String(from: dataProvider) as! T
//
//        case is UInt8.Type: return try UInt8(from: dataProvider) as! T
//        case is UInt16.Type: return try UInt16(from: dataProvider) as! T
//        case is UInt32.Type: return try UInt32(from: dataProvider) as! T
//        case is UInt64.Type: return try UInt64(from: dataProvider) as! T
//        case is UInt.Type: return try UInt(from: dataProvider) as! T
//
//        case is Int8.Type: return try Int8(from: dataProvider) as! T
//        case is Int16.Type: return try Int16(from: dataProvider) as! T
//        case is Int32.Type: return try Int32(from: dataProvider) as! T
//        case is Int64.Type: return try Int64(from: dataProvider) as! T
//        case is Int.Type: return try Int(from: dataProvider) as! T
//            
        case let a as BinaryDecodable.Type:
            return try a.init(from: dataProvider) as! T
        default:
            fatalError()
           // return try T.init(from: self)
        }
    }
}
