import Foundation

enum ProtobufEncodingError: Error {
    
    case missingIntegerCodingKey(CodingKey)
    
    case notImplemented
    
    /**
     A string value can't be represented using UTF-8 encoding.
     */
    case stringNotRepresentableInUTF8(_ failingString: String)
    
    case multipleValuesEncodedInSingleValueContainer
    
    /**
     Multiple different containers (single, keyed, unkeyed) where requested from an encoder.
     */
    case multipleTopLevelContainersRequested
}
