import Foundation

/**
 A protocol adopted by primitive types which can be converted to a binary representation which is platform-independent.
 
 In order to provide full protocol conformance, the following must be true for all values:
 ```
 let converted = value.hostIndependentRepresentation
 value == .init(fromHostIndependentRepresentation: converted) // true
 ```
 */
public protocol HostIndependentRepresentable {
    
    /// The type storing the platform-independent representation
    associatedtype IndependentType
    
    /// The value converted to a platform-independent format
    var hostIndependentRepresentation: IndependentType { get }
    
    /**
     Create a value from a platform-independent representation.
     
     - Parameter value: The host-independent representation to convert into a value.
     */
    init(fromHostIndependentRepresentation value: IndependentType)
}

extension HostIndependentRepresentable {
    
    /// Convert a value to host-independent binary data.
    var hostIndependentBinaryData: Data {
        var target = hostIndependentRepresentation
        return withUnsafeBytes(of: &target) {
            Data($0)
        }
    }
}
