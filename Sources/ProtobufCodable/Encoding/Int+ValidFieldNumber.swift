import Foundation

extension Int {

    /// Indicate if the integer key is valid as a protobuf field number
    var isValidProtobufFieldNumber: Bool {
        guard self > 0 else {
            return false
        }
        guard self <= 536_870_911 else {
            return false
        }
        return self < 19_000 || self > 19_999
    }
}
