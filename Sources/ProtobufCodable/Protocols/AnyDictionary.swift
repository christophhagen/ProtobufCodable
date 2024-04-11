import Foundation

/**
 A type-erased dictionary, used for detecting maps during encoding and decoding
 */
protocol AnyDictionary {

    /**
     Create an empty dictionary.
     */
    init()
}

extension Dictionary: AnyDictionary {
    
}
