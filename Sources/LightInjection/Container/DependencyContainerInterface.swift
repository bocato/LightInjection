import Foundation

/// Defines a factory that builds a dependency
public typealias LazyDependencyFactory = () -> Any

/// Defines a contract for a dependency container
public protocol DependencyContainerInterface: AnyObject {
    /// Get's a dependency from the container
    /// - Parameter arg: the type of the dependency
    func get<T>(_ arg: T.Type) throws -> T

    /// Registers a dependency factory for the given type.
    /// Note: it's instance will be built on the first time this dependency is used.
    /// - Parameters:
    ///   - factory: a dependency factory for the lazy dependency
    ///   - metaType: the dependency metatype
    func registerLazyDependency<T>(
        factory: @escaping LazyDependencyFactory,
        forMetaType metaType: T.Type
    ) throws

    /// Registers a dependency for the given type.
    /// - Parameters:
    ///   - instance: the dependency instance
    ///   - metaType: the dependency metatype
    func register<T>(
        instance: T,
        forMetaType metaType: T.Type
    ) throws
}
