import Foundation

/**
 A protocol to which all optional types can conform.

 It is used as an abstract type within switch cases, since optionals can't be used directly (due to their associated types)
 */
protocol AnyOptional {

    /// The optional value is nil
    var isNil: Bool { get }

    /// The nil case of the optional
    static var nilValue: Self { get }

}

extension Optional: AnyOptional {

    /// The optional is equal to `nil`
    var isNil: Bool {
        self == nil
    }

    /// The `nil` case of the optional
    static var nilValue: Optional<Wrapped> {
        .none
    }
}
