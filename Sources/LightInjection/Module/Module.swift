import Foundation

/// Defines the failure handler for Modules
public typealias ModuleFailureHandler =  (@autoclosure () -> String, StaticString, UInt) -> Void

/// Defines a the entry point for a Module, which will hold it's dependency container.
// swiftlint:disable: implicitly_unwrapped_optional
public protocol Module {
    /// The container for the module specific dependencies
    static var container: DependencyContainerInterface! { get set }
    /// The handler to deal with failures
    static var failureHandler: ModuleFailureHandler! { get set }
}
public extension Module { // TODO: Avoid initialization?
    // MARK: - Public API
    
    /// Initializes the module.
    /// - Parameters:
    ///   - customContainer: a custom container, that if not provided, will be assumed as the Global Container
    ///   - customFailureHandler: a custom failure handler, if you want to log anything of simply have more info about module related failures
    ///   - file: the file that called this function
    ///   - line: the line of the file that called this function
    static func initialize(
        withDependenciesContainer customContainer: DependencyContainerInterface? = nil,
        failureHandler customFailureHandler: ModuleFailureHandler? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        Self.failureHandler = customFailureHandler ?? ModuleEnvironment.moduleFailureHandler
        guard container == nil else {
            failureHandler("The container should not be initialized twice!", file, line)
            return
        }
        Self.container = customContainer ?? ModuleEnvironment.dependencyContainer
    }
    
    /// Registers a dependency factory for the given type, and stores it on the module dependencies container.
    /// Note: it's instance will be built on the first time this dependency is used.
    /// - Parameters:
    ///   - factory: a dependency factory for the lazy dependency
    ///   - metaType: the dependency metatype
    ///   - file: the file that called this function
    ///   - line: the line of the file that called this function
    static func registerLazyDependency<T>(
        factory: @escaping LazyDependencyFactory,
        forMetaType metaType: T.Type,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        do {
            try container.registerLazyDependency(
                factory: factory,
                forMetaType: metaType
            )
        } catch {
            failureHandler(error.localizedDescription, file, line)
        }
    }
    
    /// Registers a dependency for the given type and stores it on the module dependencies container.
    /// - Parameters:
    ///   - instance: the dependency instance
    ///   - metaType: the dependency metatype
    ///   - file: the file that called this function
    ///   - line: the line of the file that called this function
    static func register<T>(
        instance: T,
        forMetaType metaType: T.Type,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        do {
            try container.register(
                instance: instance,
                forMetaType: metaType
            )
        } catch {
            failureHandler(error.localizedDescription, file, line)
        }
    }
}
