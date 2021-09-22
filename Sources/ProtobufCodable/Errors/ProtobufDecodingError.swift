import Foundation

enum ProtobufDecodingError: Error {
    
    case missingData
    
    case invalidVarintEncoding
    
    case variableLengthEncodedValueOutOfRange
    
    case invalidString

    /// The decoder expected a field with value `1` while decoding a dictionary key
    case missingDictionaryKey

    /// The decoder expected a field with value `2` while decoding a dictionary value
    case missingDictionaryValue
}
