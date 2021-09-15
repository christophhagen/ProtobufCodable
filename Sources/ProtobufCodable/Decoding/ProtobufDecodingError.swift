import Foundation

enum ProtobufDecodingError: Error {
    
    case missingData
    
    case invalidVarintEncoding
    
    case variableLengthEncodedValueOutOfRange
    
    case invalidString
}
