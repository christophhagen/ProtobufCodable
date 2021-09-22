import Foundation

protocol EncodedDataProvider {

    func getEncodedData() throws -> Data

    func encodedObjects() throws -> [Data]

    func encodedDataToPrepend() throws -> Data
}

extension EncodedDataProvider {

    func encodedDataToPrepend() throws -> Data {
        .empty
    }
}
