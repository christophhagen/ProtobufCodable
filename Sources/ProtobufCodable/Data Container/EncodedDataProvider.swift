import Foundation

/**
 A type that can provide its components as  encoded binary data.
 */
protocol EncodedDataProvider {

    func encodedData() throws -> Data
}

extension Data: EncodedDataProvider {

    func encodedData() -> Data {
        self
    }
}
