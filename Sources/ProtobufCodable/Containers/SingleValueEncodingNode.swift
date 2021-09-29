import Foundation

final class SingleValueEncodingNode: CodingPathNode, SingleValueEncodingContainer {
    
    private var data: Data?
    
    private var encodedTypeInfo: String?

    var encodesNil: Bool {
        data == nil
    }
    
    func encodeNil() throws {
        self.data = nil
        self.encodedTypeInfo = "nil"
    }
    
    private func encodePrimitive(_ primitive: BinaryEncodable) throws {
        #warning("Should values be ommitted sometimes?")
//        if primitive.isDefaultValue && omitDefaultValues {
//            self.data = .empty
//            return
//        }
        self.encodedTypeInfo = "\(type(of: primitive)): \(primitive)"
        if let key = self.key {
            self.data = try primitive.encoded(withKey: key)
        } else {
            self.data = try primitive.encodedWithLengthIfNeeded()
        }
    }
    
    func encode<T>(_ value: T) throws where T: Encodable {
        switch value {
        case let primitive as BinaryEncodable:
            try encodePrimitive(primitive)
        default:
            #warning("Encode complex types in SingleValueContainer")
            fatalError()
        }
    }
}

extension SingleValueEncodingNode: EncodedDataProvider {

    func encodedData() throws -> Data {
        data ?? .empty
    }
}

extension SingleValueEncodingNode: CustomStringConvertible {
    
    var description: String {
        encodedTypeInfo ?? "\(type(of: self))"
    }
}