/// Used to automatically infer Equatable conformance to any reference type that
/// has an Equatable `id` property.
public protocol IdReferenceEquatable: Equatable, AnyObject {
    associatedtype IDType: Equatable
    var id: IDType { get }
}

extension IdReferenceEquatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
