import Foundation

/**
 A class to provide decoding functions to all decoding containers.
 */
class AbstractDecodingNode: AbstractNode {
    
    func decode<T>(elements: [DataField]?, type: T.Type, codingPath: [CodingKey]) throws -> T where T: Decodable {
        if let BaseType = T.self as? DecodablePrimitive.Type {
            return try wrapCorruptDataError(at: codingPath) {
                try BaseType.init(elements: elements) as! T
            }
        }
        if type is AnyDictionary.Type {
            return try decodeMap(elements: elements, codingPath: codingPath)
        }
        let node = DecodingNode(data: elements, codingPath: codingPath, userInfo: userInfo)
        return try type.init(from: node)
    }

    private func decodeMap<T>(elements: [DataField]?, codingPath: [CodingKey]) throws -> T where T: Decodable {
        guard let DecodableType = T.self as? DecodableContainer.Type else {
            throw DecodingError.typeMismatch(T.self, .init(codingPath: codingPath, debugDescription: "Unsupported map type"))
        }
        guard let elements else {
            return DecodableType.zero as! T
        }
        let keyValuePairs = try elements.map { (wireType, data) in
            guard wireType == .len else {
                throw DecodingError.typeMismatch(WireType.self, .init(codingPath: codingPath, debugDescription: "Invalid wire type \(wireType) for container with map element"))
            }
            return data
        }
        return try wrapCorruptDataError(at: codingPath) {
            try DecodableType.init(elements: keyValuePairs) as! T
        }
    }
}
