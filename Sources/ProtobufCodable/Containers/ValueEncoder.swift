import Foundation

final class ValueEncoder: ObjectEncoder, SingleValueEncodingContainer {

    func encodeNil() throws {
        // Nothing to do when encoding nil
    }
    
    private func encodePrimitive(_ primitive: BinaryEncodable) throws {
        if primitive.isDefaultValue && omitDefaultValues {
            return
        }
        if let key = self.key {
            try addObject {
                try primitive.encoded(withKey: key, requireIntegerKey: requireIntegerCodingKeys)
            }
        } else {
            try addObject {
                try primitive.encodedWithLengthIfNeeded()
            }
        }
    }

    private func encodeComplex<T>(_ value: T) throws where T: Encodable {
        let encoder = addObject {
            TopLevelEncoder(path: codingPath, key: key, info: userInfo)
        }
        try value.encode(to: encoder)
    }
    
    func encode<T>(_ value: T) throws where T: Encodable {
        switch value {
        case let primitive as BinaryEncodable:
            try encodePrimitive(primitive)
        default:
            try encodeComplex(value)
        }
    }
}

extension ValueEncoder: EncodedDataProvider {

    func encodedData() throws -> Data {
        try objects.reduce(.empty) { try $0 + $1.encodedData() }
    }
}

extension ValueEncoder: CustomStringConvertible {
    
    var description: String {
        "ValueEncoder"
    }
}
