//
//  AnyEncoder.swift
//  Codex
//
//  Created by incetro on 7/13/19.
//

import Foundation

// MARK: - AnyEncoder

/// Protocol acting as a common API for all types of encoders,
/// such as `JSONEncoder` and `PropertyListEncoder`.
public protocol AnyEncoder {

    /// Encode a given value into binary data.
    func encode<T: Encodable>(_ value: T) throws -> Data
}

// MARK: - JSONEncoder

extension JSONEncoder: AnyEncoder {
}
