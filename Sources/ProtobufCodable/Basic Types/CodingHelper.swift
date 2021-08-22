import Foundation

func toData<T>(_ value: T) -> Data {
    var target = value
    return withUnsafeBytes(of: &target) {
        Data($0)
    }
}

extension Data {
    
    public static var empty: Data {
        .init()
    }
    
    
    public var bytes: [UInt8] {
        Array(self)
    }
    
    var swapped: Data {
        Data(reversed())
    }
    
}

extension Array where Element == UInt8 {
    
    public var data: Data {
        .init(self)
    }
}

extension String {
    
    public static var empty: String {
        ""
    }
}
