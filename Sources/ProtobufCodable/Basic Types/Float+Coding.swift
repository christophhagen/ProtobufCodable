import Foundation

extension Float: BinaryPrimitiveEncodable {
    
    public func binaryData() -> Data {
        toData(CFConvertFloatHostToSwapped(self)).swapped
    }
    
    public var wireType: WireType {
        .length32
    }
}
