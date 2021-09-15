import Foundation
/*
final class ValueDecoder: SingleValueDecodingContainer {
    
    var codingPath: [CodingKey]
    
    private let data: DataProvider
    
    let field: Int?
    
    private let containsNil: Bool
    
    init(codingPath: [CodingKey], data: Data, field: Int?) throws {
        self.codingPath = codingPath
        // If the container has no field assigned, then it is a top level object
        // This means that a leading byte is appended to indicate the presence of nil values
        if let f = field {
            self.containsNil = data.isEmpty
            self.data = DataProvider(data: data)
            self.field = f
        } else {
            self.containsNil = data.first ?? 0 == 0
            self.data = DataProvider(data: data.dropFirst())
            self.field = nil
        }
    }
    
    func decodeNil() -> Bool {
        containsNil
    }
    
    func decode(_ type: Bool.Type) throws -> Bool {
        try .init(from: data)
    }
    
    func decode(_ type: String.Type) throws -> String {
        fatalError()
    }
    
    func decode(_ type: Double.Type) throws -> Double {
        fatalError()
    }
    
    func decode(_ type: Float.Type) throws -> Float {
        fatalError()
    }
    
    func decode(_ type: Int.Type) throws -> Int {
        fatalError()
    }
    
    func decode(_ type: Int8.Type) throws -> Int8 {
        fatalError()
    }
    
    func decode(_ type: Int16.Type) throws -> Int16 {
        fatalError()
    }
    
    func decode(_ type: Int32.Type) throws -> Int32 {
        fatalError()
    }
    
    func decode(_ type: Int64.Type) throws -> Int64 {
        fatalError()
    }
    
    func decode(_ type: UInt.Type) throws -> UInt {
        fatalError()
    }
    
    func decode(_ type: UInt8.Type) throws -> UInt8 {
        fatalError()
    }
    
    func decode(_ type: UInt16.Type) throws -> UInt16 {
        fatalError()
    }
    
    func decode(_ type: UInt32.Type) throws -> UInt32 {
        fatalError()
    }
    
    func decode(_ type: UInt64.Type) throws -> UInt64 {
        fatalError()
    }
    
    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        fatalError()
    }
}
*/
