import Foundation

/**
 A protocol adopted by primitive types for encoding.
 */
protocol EncodableContainer {

    /**
     Encode the contained value(s) for an unkeyed container.
     */
    func encodeForUnkeyedContainer() throws -> Data

    /**
     Encode for a keyed container using the provided key.
     */
    func encode(forKey key: Int) throws -> Data
}
