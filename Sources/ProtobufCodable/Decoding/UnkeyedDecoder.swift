import Foundation

/**
 Unkeyed decoders are used for protobuf repeated and map fields.

 They are somewhat complex, since:
 - The concrete type of the contained elements is not known when the decoder is created
 - Primitive types (any scalar type that is not `string` or `bytes`) can be packed, where the data type is `variableLength`, and multiple elements are contained each element
 - The elements of multiple fields must be concatenated
 - Default values are not skipped in unkeyed containers
 */
final class UnkeyedDecoder: AbstractDecodingNode, UnkeyedDecodingContainer {

    /**
     The number of values in the unkeyed container.

     This property is `nil` until the first element is decoded.

     - Note: Count can't be known before first element is decoded, due to the possibility of packed values.
     */
    private(set) var count: Int? = nil

    /**
     Indicates if all elements have been decoded
     */
    private(set) var isAtEnd = false

    /// The number of elements already decoded
    private(set) var currentIndex: Int = 0

    private let data: [DataField]

    /// The current index into the `data` array
    private var dataIndex = 0

    /// The current index into the data at `data[dataIndex].data`
    private var dataElementIndex: Data.Index

    /// The type of the first decoded element, to ensure that all elements are of the same type
    private var detectedType: Any.Type?

    init(data: [DataField]?, codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) throws {
        // If a field with an unkeyed container is not set, then it is treated as the default, which is an empty array
        guard let data, let firstIndex = data.first?.data.startIndex else {
            self.data = []
            self.isAtEnd = true
            self.dataElementIndex = 0
            super.init( codingPath: codingPath, userInfo: userInfo)
            return
        }
        self.data = data
        self.dataElementIndex = firstIndex
        super.init( codingPath: codingPath, userInfo: userInfo)
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        throw DecodingError.notSupported("Nested keyed containers are not supported in unkeyed containers", codingPath: codingPath)
    }

    func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        throw DecodingError.notSupported("Nested unkeyed containers are not supported in unkeyed containers", codingPath: codingPath)
    }

    func superDecoder() throws -> Decoder {
        throw DecodingError.notSupported("Decoding super is not supported", codingPath: codingPath)
    }

    func decodeNil() throws -> Bool {
        throw DecodingError.notSupported("Nil values are not supported in unkeyed containers", codingPath: codingPath)
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        guard !isAtEnd else {
            throw DecodingError.dataCorrupted(.init(codingPath: codingPath, debugDescription: "No more elements to decode in unkeyed container"))
        }

        if let BaseType = T.self as? DecodablePrimitive.Type {
            // Ensure that current element matches the previous ones
            try setTypeOfContainedElements(type: type, wireType: BaseType.wireType)

            if BaseType.wireType != .len {
                // Decode a scalar type that could be inside a "packed" field
                return try decodeScalarType(BaseType.self) as! T
            }
            // Decode the field as single value with complete field data, advance index
            return try decodeSingleValue(BaseType.self, wireType: BaseType.wireType) as! T
        }
        // Type is complex, decode single element
        let element = try getNextData(type: type, wireType: .len)

        let node = DecodingNode(data: [element], codingPath: codingPath, userInfo: userInfo)
        return try type.init(from: node)
    }

    private func decodeScalarType<T>(_ type: T.Type) throws -> T where T: DecodablePrimitive {
        // Scalar types can be "packed"
        // If the data type of an element in `data` matches, then decode the scalar directly
        // If the data type of the element is `variableLength`, then multiple values are contained in the element, decode one by one

        let elementType = data[dataIndex].type
        if elementType == .len {
            // Data is "packed", decode one element from current field
            return try decodePackedElement()
        }
        // Decode element with complete field data, advance index
        return try decodeSingleValue(T.self, wireType: elementType)
    }

    private func decodePackedElement<T>() throws -> T where T: DecodablePrimitive {
        let data = data[dataIndex].data

        let elementData = try data.decodeNextElement(of: T.wireType, at: &dataElementIndex)
        let decoded = try T.init(data: elementData)

        // Advance indices
        if dataElementIndex >= data.endIndex {
            // Move to next container
            moveToNextFieldAfterDecodingElement()
        } else {
            // Data index already advanced, only update element index
            self.currentIndex += 1
        }

        return decoded
    }

    /**
     Decode a single value from the current field, using all bytes.

     This functions is used for fields that are not "packed".
     */
    private func decodeSingleValue<T>(_ type: T.Type, wireType: WireType) throws -> T where T: DecodablePrimitive {
        let data = try getNextData(type: type, wireType: wireType).data

        let decoded = try T.init(data: data)

        // Advance indices to next field
        moveToNextFieldAfterDecodingElement()

        return decoded
    }

    private func getNextData<T>(type: T.Type, wireType: WireType) throws -> DataField {
        let element = data[dataIndex]
        guard element.type == wireType else {
            throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: "Unkeyed container found field with data type \(element.type), but expected \(wireType))"))
        }
        guard self.dataElementIndex == element.data.startIndex else {
            throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: "Attempting to decode non-packed \(type) from field which already decoded a packed value."))
        }
        return element
    }

    private func moveToNextFieldAfterDecodingElement() {
        self.currentIndex += 1
        if dataIndex + 1 >= data.count {
            self.isAtEnd = true
        } else {
            self.dataIndex += 1
            self.dataElementIndex = data[dataIndex].data.startIndex
        }
    }

    // MARK: - Element data types

    /**
     Either set the type of element to expect for all contained values, or ensure that the current type matches previous ones
     */
    private func setTypeOfContainedElements(type: Any.Type, wireType: WireType) throws {
        if let detectedType {
            // One element was already decoded, ensure that the current one matches
            if detectedType != type {
                throw DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: "Unkeyed container only supports one contained type (previously decoded \(detectedType), now \(type))"))
            }
            return
        }
        // First element decoded, check that all decoded data types match
        self.detectedType = type
        self.count = determineNumberOfElements(of: wireType)
        try ensureElementsHave(type: wireType)
    }

    /**
     Ensure that all fields have the correct data type.

     For primitive types (non-varLen), a `variableLength` element is also allowed, since it means there are `packed` fields.
     */
    private func ensureElementsHave(type: WireType) throws {
        for element in data {
            if element.type != type && element.type != .len {
                throw DecodingError.typeMismatch(WireType.self, .init(codingPath: codingPath, debugDescription: "Unkeyed container only supports one contained type (previously decoded \(type), but field is \(element.type))"))
            }
        }
    }

    /**
     Count the total number of elements in the container, assuming the given type.

     The type must be known to count the elements, since packed fields could contain a different number of elements depending on the selected type.
     For example, a packed field with 8 bytes could contain one `Double` or two `Float`s.
     */
    private func determineNumberOfElements(of type: WireType) -> Int {
        switch type {
        case .varInt:
            // For varints, each value has only one sign bit unset
            // So we just count the number of bytes without a sign bit
            return data.sum { $0.data.count(isIncluded: { $0 & 0x80 == 0 }) }
        case .i64:
            return countElements(size: 8)
        case .len:
            // Variable length values can't be packed
            return data.count
        case .i32:
            return countElements(size: 4)
        }
    }

    /**
     Count the number of elements assuming a fixed size for each element.

     Packed fields can contain multiple elements chained together.
     */
    private func countElements(size: Int) -> Int {
        data.sum { $0.data.count / size }
    }

}
