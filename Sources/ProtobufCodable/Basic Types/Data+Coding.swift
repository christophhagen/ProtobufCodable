import Foundation

extension Data: BinaryPrimitiveEncodable {
    
    public func binaryData() throws -> Data {
        self
    }
    
    public var wireType: WireType {
        .lengthDelimited
    }
}
