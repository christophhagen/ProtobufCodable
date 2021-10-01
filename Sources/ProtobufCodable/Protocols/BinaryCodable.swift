import Foundation

/**
 A type that can convert itself into and out of binary data.

 `BinaryCodable` is a type alias for the ``BinaryEncodable`` and ``BinaryEncodable`` protocols. When you use `BinaryCodable` as a type or a generic constraint, it matches any type that conforms to both protocols.
 */
typealias BinaryCodable = BinaryDecodable & BinaryEncodable
