//
//  AnyDecoder.swift
//  Codex
//
//  Created by incetro on 11/30/20.
//

import Foundation

// MARK: - AnyDecoder

/// Protocol acting as a common API for all types of decoders,
/// such as `JSONDecoder` and `PropertyListDecoder`.
public protocol AnyDecoder {

    /// Decode a value of a given type from binary data.
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
}

// MARK: - JSONDecoder

extension JSONDecoder: AnyDecoder {
}
