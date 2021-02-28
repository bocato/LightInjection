import Foundation

/// Defines a failure handler for a dependency resolver, which returns the failure reason as a String
public typealias DependencyResolverFailureHandler = (String) -> Void

/// Defines a resolvable dependency, which is able to resolve itself using a store.
// swiftlint:disable: implicitly_unwrapped_optional
@propertyWrapper
public final class Dependency<T> {
    // MARK: - Dependencies

    private var resolvedValue: T!
    private var userResolved = false
    let container: DependencyContainerInterface
    let failureHandler: DependencyResolverFailureHandler

    // MARK: - Properties

    public var wrappedValue: T! {
        resolveIfNeeded()
        return resolvedValue
    }

    // MARK: - Initialization

    required init(
        resolvedValue: T?,
        resolver: DependencyContainerInterface,
        failureHandler: @escaping DependencyResolverFailureHandler = { msg in preconditionFailure(msg) }
    ) {
        self.resolvedValue = resolvedValue
        container = resolver
        self.failureHandler = failureHandler
    }

    public convenience init(resolver: DependencyContainerInterface) {
        self.init(
            resolvedValue: nil,
            resolver: resolver
        )
    }

    public convenience init() {
        self.init(
            resolvedValue: nil,
            resolver: DependencyContainer.global
        )
    }

    // MARK: - Public Methods

    public static func resolved(_ instance: T) -> Self {
        let instance: Self = .init(
            resolvedValue: instance,
            resolver: DependencyContainer.global
        )
        instance.userResolved = true
        return instance
    }

    // MARK: - Private Methods

    private func resolveIfNeeded() {
        guard resolvedValue == nil else {
            if userResolved == false {
                failureHandler("Attempted to resolve \(String(describing: T.self)) twice!")
            }
            return
        }

        do {
            resolvedValue = try container.get(T.self)
        } catch {
            failureHandler(error.localizedDescription)
        }
    }
}
