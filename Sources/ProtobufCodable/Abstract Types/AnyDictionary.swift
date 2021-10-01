import Foundation

/**
 A protocol to which all dictionary types can conform.

 It is used as an abstract type within switch cases, since Dictionaries can't be used directly (due to their associated types)
 */
protocol AnyDictionary {

    /**
     Create an empty dictionary.
     */
    init()
}

extension Dictionary: AnyDictionary {
    
}
