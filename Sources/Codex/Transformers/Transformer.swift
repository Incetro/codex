//
//  Transformer.swift
//  Codex
//
//  Created by incetro on 3/25/21.
//

import Foundation

// MARK: - Transformer

public protocol Transformer {

    associatedtype Object: Codable
    associatedtype JSON: Codable

    /// Transforms some json to some object
    /// - Parameter json: some json value
    func transform(json: Any) -> Object?

    /// Tranforms some object to json value
    /// - Parameter object: some object
    func transform(object _: Object) -> JSON?
}
