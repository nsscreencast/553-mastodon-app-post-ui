import Foundation

public extension URL {
    init(_ staticString: StaticString) {
        self.init(string: "\(staticString)")!
    }
}
