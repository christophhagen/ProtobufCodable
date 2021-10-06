import Foundation

/**
 Decoding data structure containing a repeated field and an index set with nil values.
 */
struct DataWithNilIndex {

    /// The data encoded for the field
    let provider: DecodingDataProvider

    /// The set of indices in the data where nil values are present
    var nilIndices: Set<Int>

    /// The index of the value currently being decoded
    var currentIndex: Int = 0

    /// The repeated field has no more data
    var isAtEnd: Bool {
        provider.isAtEnd && nilIndices.isEmpty
    }

    /// The next index in the sequence is a `nil` value
    var nextValueIsNil: Bool {
        nilIndices.contains(currentIndex)
    }

    /**
     Increment the index and move to the next value.
     
     This function is called for decoded values and nil indices.
     */
    mutating func didDecodeValue() {
        nilIndices.remove(currentIndex)
        currentIndex += 1
    }
}
