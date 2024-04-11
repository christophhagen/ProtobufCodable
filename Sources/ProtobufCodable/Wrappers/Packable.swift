import Foundation

public protocol Packable {

    /**
     Encode the value with the key, even if it is a default value.

     - Note: This function is needed for unkeyed containers that are not packed.
     */
    func encodeAlways(forKey key: Int) -> Data
}

