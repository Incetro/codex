//
//  Encodable.swift
//  Codex
//
//  Created by incetro on 11/30/20.
//

import Foundation

// MARK: - Encodable

public extension Encodable {

    /// Encode this value, optionally using a specific encoder.
    /// If no explicit encoder is passed, then the value is encoded into JSON.
    func encoded(using encoder: AnyEncoder = JSONEncoder()) throws -> Data {
        try encoder.encode(self)
    }
}
