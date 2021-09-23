import Foundation

protocol EncodedDataProvider {

    func encodedObjects() throws -> [EncodedDataWrapper]

    func encodedDataToPrepend() throws -> EncodedDataWrapper?
}

extension EncodedDataProvider {

    func encodedDataToPrepend() throws -> EncodedDataWrapper? {
        nil
    }
}

extension EncodedDataProvider {

    func encodedDataWithoutField(includeLengthIfNeeded includeLength: Bool) throws -> Data {
        try encodedObjects()
            .map { $0.encoded(withLengthIfNeeded: includeLength) }
            .reduce(.empty, +)
//        guard let prepend = try encodedDataToPrepend() else {
//            return data
//        }
//        return prepend.data + data
    }
}
