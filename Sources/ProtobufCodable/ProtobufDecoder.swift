//
//  File.swift
//  
//
//  Created by iMac on 09.09.21.
//

import Foundation

public struct ProtobufDecoder {
    
    public init() {
        
    }
    
    public func decode<T>(_ type: T.Type = T.self, from data: Data) throws -> T where T: Decodable {
        if type is AnyDictionary.Type {
            let decoder = DictionaryDecodingNode(codingPath: [], userInfo: [:], data: data)
            return try .init(from: decoder)
        } else {
            let decoder = TopLevelDecodingContainer(codingPath: [], userInfo: [:], data: data)
            return try .init(from: decoder)
        }

    }
}
