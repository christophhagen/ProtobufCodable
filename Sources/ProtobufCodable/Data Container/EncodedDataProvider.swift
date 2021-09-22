import Foundation

protocol EncodedDataProvider {

    func encodedObjects() throws -> [EncodedDataWrapper]

    func encodedDataToPrepend() throws -> Data
}

extension EncodedDataProvider {

    func encodedDataToPrepend() throws -> Data {
        .empty
    }
}

extension EncodedDataProvider {

    func encodedDataWithoutField(includeLengthIfNeeded includeLength: Bool) throws -> Data {
        try encodedDataToPrepend() + encodedObjects()
            .map { $0.encoded(withLengthIfNeeded: includeLength) }
            .reduce(.empty, +)
    }
}
