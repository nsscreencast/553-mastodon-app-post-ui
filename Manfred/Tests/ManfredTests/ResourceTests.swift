import Foundation
import XCTest
@testable import Manfred

class ResourceTests: XCTestCase {
    let decoder = JSONDecoder.mastodon

    func testDecodeStatus() throws {
        let statusJSON = try loadFixture("status.json")
        let status = try decoder.decode(Status.self, from: statusJSON)

        XCTAssertEqual(status.id, "109557790420259464")
        XCTAssertEqual(status.createdAt, Date(iso8601WithFractionalSeconds: "2022-12-22T14:26:44.000Z"))
        XCTAssertNil(status.inReplyToId)
        XCTAssertNil(status.inReplyToAccountId)
        XCTAssertFalse(status.sensitive)
        XCTAssertEqual(status.spoilerText, "")
        XCTAssertEqual(status.visibility, .public)
        XCTAssertEqual(status.language, "es")
        XCTAssertEqual(status.uri, URL("https://tkz.one/users/Zebramon/statuses/109557789775327050"))
        XCTAssertEqual(status.url, URL("https://tkz.one/@Zebramon/109557789775327050"))
        XCTAssertEqual(status.content, "\u{003c}p\u{003e}Que bonito es mob psycho\u{003c}/p\u{003e}")
        XCTAssertNil(status.reblog)
        XCTAssertEqual(status.reblogsCount, 0)
        XCTAssertEqual(status.favoritesCount, 0)
    }
}

extension Date {
    static let formatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter
    }()

    init?(iso8601WithFractionalSeconds input: String) {
        guard let date = Self.formatter.date(from: input) else {
            return nil
        }
        self = date
    }
}

struct MissingFixture: Error {
    let name: String
}

func loadFixture(_ name: String) throws -> Data {
    guard let path = Bundle.module
        .path(forResource: name, ofType: nil, inDirectory: "Fixtures")
    else {
        throw MissingFixture(name: name)
    }

    return try Data(contentsOf: URL(fileURLWithPath: path))
}
