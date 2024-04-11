import Foundation

/// A protocol adopted by all types valid as keys for protobuf maps, e.g. scalars and String
typealias ProtobufMapKey = EncodableMapKey & DecodableMapKey

protocol EncodableMapKey: EncodableContainer {

}

protocol DecodableMapKey: DecodablePrimitive {

}
