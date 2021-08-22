import Foundation

extension Double: BinaryPrimitiveEncodable {
    
    public func binaryData() -> Data {
        toData(CFConvertDoubleHostToSwapped(self)).swapped
    }
    
    public var wireType: WireType {
        .length64
    }
}

