import Foundation

protocol DecodableContainer {

    static var zero: Self { get }

    init(elements: [Data]) throws
}
