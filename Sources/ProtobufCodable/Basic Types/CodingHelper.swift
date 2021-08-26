import Foundation

extension Data {
    
    /// An empty data instance
    public static var empty: Data {
        .init()
    }
    
    /// The data converted to a byte array
    public var bytes: [UInt8] {
        Array(self)
    }
    
    /// The data in reverse ordering
    var swapped: Data {
        Data(reversed())
    }
    
}

extension Array where Element == UInt8 {
    
    /// The array converted to data
    public var data: Data {
        .init(self)
    }
}

extension String {
    
    /// An empty string
    public static var empty: String {
        ""
    }
}
