//
//  AnyDateFormatter.swift
//  Codex
//
//  Created by incetro on 11/30/20.
//

import Foundation

// MARK: - AnyDateFormatter

/// Protocol acting as a common API for all types of date formatters,
/// such as `DateFormatter` and `ISO8601DateFormatter`.
public protocol AnyDateFormatter {

    /// Format a string into a date
    func date(from string: String) -> Date?

    /// Format a date into a string
    func string(from date: Date) -> String
}

// MARK: - DateFormatter

extension DateFormatter: AnyDateFormatter {
}

// MARK: - ISO8601DateFormatter

@available(iOS 10.0, macOS 10.12, tvOS 10.0, *)
extension ISO8601DateFormatter: AnyDateFormatter {
}
