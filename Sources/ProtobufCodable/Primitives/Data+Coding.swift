import Foundation

extension Data: EncodablePrimitive {

    var protoTypeName: String {
        "bytes"
    }

    static var zero: Data {
        Data()
    }

    var encodedData: Data {
        self
    }

    var needsLengthData: Bool {
        true
    }
}

extension Data: DecodablePrimitive {

    static var wireType: WireType {
        .len
    }

    init(data: Data) {
        self = data
    }
}
