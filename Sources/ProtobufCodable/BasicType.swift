import Foundation

/**
 The basic types encodable in Protocol Buffers.
 */
enum PrimitiveType {
    
    /**
     A double value (64 bit)
     */
    case double
    
    /**
     A float value (32 bit)
     */
    case float
    
    /**
     A 32-bit signed integer value.
     
     Uses variable-length encoding. Inefficient for encoding negative numbers – if your field is likely to have negative values, use sint32 instead.
     */
    case int32
    
    /**
     A 64-bit signed integer value.
     
     Uses variable-length encoding. Inefficient for encoding negative numbers – if your field is likely to have negative values, use sint64 instead.
     */
    case int64
    
    /**
     A 32-bit unsigned integer value.
     
     Uses variable-length encoding.
     */
    case uint32
    
    /**
     A 64-bit unsigned integer value.
     
     Uses variable-length encoding.
     */
    case uint64
    
    /**
     A 32-bit signed integer value.
     
     Uses variable-length encoding. Signed int value. These more efficiently encode negative numbers than regular int32s.
     */
    case sint32
    
    /**
     A 64-bit signed integer value.
     
     Uses variable-length encoding. Signed int value. These more efficiently encode negative numbers than regular int32s.
     */
    case sint64
    
    /**
     A 32-bit unsigned integer value.
     
     Always four bytes. More efficient than uint32 if values are often greater than 2^28.
     */
    case fixed32
    
    /**
     A 64-bit unsigned integer value.
     
     Always eight bytes. More efficient than uint64 if values are often greater than 2^56.
     */
    case fixed64
    
    /**
     A 32-bit signed integer value.
     
     Always four bytes.
     */
    case sfixed32
    
    /**
     A 64-bit signed integer value.
     
     Always eight bytes.
     */
    case sfixed64
    
    /**
     A boolean value.
     */
    case bool
    
    /**
     A string value.
     
     A string must always contain UTF-8 encoded or 7-bit ASCII text, and cannot be longer than 2^32.
     */
    case string
    
    /**
     Binary data.
     
     May contain any arbitrary sequence of bytes no longer than 2^32.
     */
    case bytes
}
