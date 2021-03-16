//
//  MainTests.swift
//  Codex
//
//  Created by Дмитрий Савинов on 23.11.2020.
//

import XCTest
import Codex

// MARK: - MainTest

final class MainTest: XCTestCase {

    func testEncodingAndDecoding() throws {

        /// given

        struct Book: Codable, Equatable {
            let title:  String
            let author: String
            let year:   Int
        }

        let book = Book(
            title: "The Swift Programming Language",
            author: "Apple",
            year: 2014
        )

        /// when

        let data    = try book.encoded()
        let decoded = try data.decoded() as Book

        /// then

        XCTAssertEqual(book, decoded)
    }

    func testDecodeIfPresent() throws {

        /// given

        struct User: Decodable, Equatable {

            let firstName:  String
            let secondName: String?
            let thirdName:  String?

            init(from decoder: Decoder) throws {
                firstName  = try decoder.decode("firstName")
                secondName = try decoder.decodeIfPresent("secondName")
                thirdName  = try decoder.decodeIfPresent("thirdName")
            }
        }

        /// when

        let user = try Data(#"{"firstName": "firstName", "secondName": "secondName"}"#.utf8).decoded() as User

        /// then

        XCTAssertEqual(user.firstName, "firstName")
        XCTAssertEqual(user.secondName, "secondName")
        XCTAssertNil(user.thirdName)
    }

    func testDecodeIfPresentTypeMismatch() throws {

        /// given

        struct Book: Codable, Equatable {
            let title:  String
            let author: String
            let year:   Int
        }

        /// when & then

        do {
            let _ = try Data(#"{"title": "title", "author": "author", "year": "2014"}"#.utf8).decoded() as Book
            XCTFail("Decoding expected to fail due to type mismatch.")
        } catch DecodingError.typeMismatch {
            return
        } catch {
            XCTFail("Expected `typeMismatch` error.")
        }
    }

    func testSingleValue() throws {

        /// given

        struct Book: Codable, Equatable {

            let title: String

            init(title: String) {
                self.title = title
            }

            init(from decoder: Decoder) throws {
                title = try decoder.decodeSingleValue()
            }

            func encode(to encoder: Encoder) throws {
                try encoder.encodeSingleValue(title)
            }
        }

        /// when

        let books   = [Book(title: "The Swift Programming Language")]
        let data    = try books.encoded()
        let decoded = try data.decoded() as [Book]

        /// then

        XCTAssertEqual(books, decoded)
    }

    func testUsingStringAsKey() throws {

        /// given

        struct Book: Codable, Equatable {

            let title: String

            init(title: String) {
                self.title = title
            }

            init(from decoder: Decoder) throws {
                title = try decoder.decode("title")
            }

            func encode(to encoder: Encoder) throws {
                try encoder.encode(title, for: "title")
            }
        }

        /// when

        let book    = [Book(title: "The Swift Programming Language")]
        let data    = try book.encoded()
        let decoded = try data.decoded() as [Book]

        /// then

        XCTAssertEqual(book, decoded)
    }

    func testUsingCodingKey() throws {

        /// given

        struct Book: Codable, Equatable {

            enum CodingKeys: CodingKey {
                case title
            }

            let title: String

            init(title: String) {
                self.title = title
            }

            init(from decoder: Decoder) throws {
                title = try decoder.decode(CodingKeys.title)
            }

            func encode(to encoder: Encoder) throws {
                try encoder.encode(title, for: CodingKeys.title)
            }
        }

        /// when

        let book    = [Book(title: "The Swift Programming Language")]
        let data    = try book.encoded()
        let decoded = try data.decoded() as [Book]

        /// then

        XCTAssertEqual(book, decoded)
    }

    func testDateWithCustomFormatter() throws {

        struct Book: Codable, Equatable {

            /// given

            static func makeDateFormatter() -> DateFormatter {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                formatter.timeZone = TimeZone(secondsFromGMT: 0)
                return formatter
            }

            let releaseDate: Date

            init(releaseDate: Date) {
                self.releaseDate = releaseDate
            }

            init(from decoder: Decoder) throws {
                let formatter = Book.makeDateFormatter()
                releaseDate = try decoder.decode("releaseDate", using: formatter)
            }

            func encode(to encoder: Encoder) throws {
                let formatter = Book.makeDateFormatter()
                try encoder.encode(releaseDate, for: "releaseDate", using: formatter)
            }
        }

        /// when

        let book      = Book(releaseDate: Date())
        let data      = try book.encoded()
        let decoded   = try data.decoded() as Book
        let formatter = Book.makeDateFormatter()

        /// then

        XCTAssertEqual(
            formatter.string(from: book.releaseDate),
            formatter.string(from: decoded.releaseDate)
        )
    }

    @available(iOS 10.0, macOS 10.12, tvOS 10.0, *)
    func testDateWithISO8601Formatter() throws {

        /// given

        struct Book: Codable, Equatable {

            let releaseDate: Date

            init(releaseDate: Date) {
                self.releaseDate = releaseDate
            }

            init(from decoder: Decoder) throws {
                let formatter = ISO8601DateFormatter()
                releaseDate = try decoder.decode("releaseDate", using: formatter)
            }

            func encode(to encoder: Encoder) throws {
                let formatter = ISO8601DateFormatter()
                try encoder.encode(releaseDate, for: "releaseDate", using: formatter)
            }
        }

        /// when

        let book      = Book(releaseDate: Date())
        let data      = try book.encoded()
        let decoded   = try data.decoded() as Book
        let formatter = ISO8601DateFormatter()

        /// then

        XCTAssertEqual(
            formatter.string(from: book.releaseDate),
            formatter.string(from: decoded.releaseDate)
        )
    }

    func testDecodingErrorThrownForInvalidDateString() {

        /// given

        struct Book: Decodable, Equatable {

            let releaseDate: Date

            init(releaseDate: Date) {
                self.releaseDate = releaseDate
            }

            init(from decoder: Decoder) throws {
                releaseDate = try decoder.decode("releaseDate", using: DateFormatter())
            }
        }

        /// when

        let data = Data(#"{"releaseDate": "releaseDate"}"#.utf8)

        /// then

        XCTAssertThrowsError(try data.decoded() as Book) { error in
            XCTAssertTrue(error is DecodingError, "Expected DecodingError but got \(type(of: error))")
        }
    }

    func testDecodingNested() throws {

        /// given

        struct Book: Decodable, Equatable {

            let title: String

            init(title: String) {
                self.title = title
            }

            init(from decoder: Decoder) throws {
                title = try decoder.decode(["data", "nested", "title"])
            }
        }

        /// when

        let jsonString = #"""
         {
             "data": {
                 "nested": {
                     "title": "Good book"
                 }
             }
         }
         """#

        let value = try Data(jsonString.utf8).decoded() as Book

        /// then

        XCTAssertEqual(value.title, "Good book")
    }

    func testDecodingStringNested() throws {

        /// given

        struct Book: Decodable, Equatable {

            let title: String

            init(title: String) {
                self.title = title
            }

            init(from decoder: Decoder) throws {
                title = try decoder.decode(nestedBy: "data.nested.title")
            }
        }

        /// when

        let jsonString = #"""
         {
             "data": {
                 "nested": {
                     "title": "Good book"
                 }
             }
         }
         """#

        let value = try Data(jsonString.utf8).decoded() as Book

        /// then

        XCTAssertEqual(value.title, "Good book")
    }

    func testDecodingSingleValueNested() throws {

        /// given

        struct Book: Decodable, Equatable {

            let title: String

            init(title: String) {
                self.title = title
            }

            init(from decoder: Decoder) throws {
                title = try decoder.decode(["title"])
            }
        }

        /// when
        
        let value = try Data(#"{"title": "Good book"}"#.utf8).decoded() as Book

        /// then

        XCTAssertEqual(value.title, "Good book")
    }

    func testDecodingNestedWithEmptyKeysThrows() {

        /// given

        struct Book: Decodable, Equatable {

            let title: String

            init(title: String) {
                self.title = title
            }

            init(from decoder: Decoder) throws {
                title = try decoder.decode([String]())
            }
        }

        /// when

        let data = Data(#"{"title": "Good book"}"#.utf8)

        /// then

        XCTAssertThrowsError(try data.decoded() as Book) { error in
            XCTAssertEqual(
                error as? CodexDecodingError,
                CodexDecodingError.emptyCodingKey,
                "Expected CodexDecodingError.emptyCodingKey but got \(error)"
            )
        }
    }

    func testDecodeUsingStringAsKeyWithDefaultValueOptional() {

        /// given

        struct Book: Codable {

            var publisher: String?

            init(publisher: String) {
                self.publisher = publisher
            }

            init(from decoder: Decoder) throws {
                publisher = try decoder.decode("publisher", defaultValue: self.publisher)
            }

            func encode(to encoder: Encoder) throws {
                try encoder.encode(publisher, for: "publisher")
            }
        }

        /// when & then

        let empty = "{}".data(using: .utf8)!
        XCTAssertNoThrow(try empty.decoded() as Book)
        let dataChangedKey = "{\"changedKey\": \"Hello, world!\"}".data(using: .utf8)!
        XCTAssertNoThrow(try dataChangedKey.decoded() as Book)
        let dataNull = "{\"string\": null}".data(using: .utf8)!
        XCTAssertNoThrow(try dataNull.decoded() as Book)
    }

    func testDecodeUsingStringAsKeyWithDefaultValue() {

        /// given

        struct Book: Codable {

            var publisher: String = "MIF"

            init(publisher: String) {
                self.publisher = publisher
            }

            init(from decoder: Decoder) throws {
                publisher = try decoder.decode("publisher", defaultValue: self.publisher)
            }

            func encode(to encoder: Encoder) throws {
                try encoder.encode(publisher, for: "publisher")
            }
        }

        /// when & then

        let empty = "{}".data(using: .utf8)!
        XCTAssertNoThrow(try empty.decoded() as Book)
        let dataChangedKey = "{\"changedKey\": \"Hello, world!\"}".data(using: .utf8)!
        XCTAssertNoThrow(try dataChangedKey.decoded() as Book)
        let dataNull = "{\"string\": null}".data(using: .utf8)!
        XCTAssertNoThrow(try dataNull.decoded() as Book)
    }
}
