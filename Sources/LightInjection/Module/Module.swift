import Foundation

/// Defines the failure handler for Modules
public typealias ModuleFailureHandler =  (@autoclosure () -> String, StaticString, UInt) -> Void

/// Defines the type of container  to use for the module.
public enum ModuleContainerOption {
    /// Uses the Global/  Shared `DependencyContainer` to hold the module's dependencies.
    case global
    /// Creates an exclusive `DependencyContainer` to hold the module's dependencies.
    case exclusive
    /// Provides a custom `DependencyContainer` to hold the module's dependencies.
    case custom(DependencyContainerInterface)
}

/// Defines a the entry point / context holder for a Module, which will hold it's dependency container.
// swiftlint:disable: implicitly_unwrapped_optional
public protocol Module {
    /// The container for the module specific dependencies
    static var container: DependencyContainerInterface! { get set }
}
public extension Module {
    /// Initializes the module.
    /// - Parameters:
    ///   - container: defines which container will hold the module dependencies, based on the `ModuleContainerOption` provided, the default value is the to use the Global / Sahred Container.
    ///   - customFailureHandler: a custom failure handler, if you want to log anything of simply have more info about module related failures
    ///   - file: the file that called this function
    ///   - line: the line of the file that called this function
    static func initialize(
        container containerOption: ModuleContainerOption = .global,
        failureHandler customFailureHandler: ModuleFailureHandler? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let failureHandler = customFailureHandler ?? LightInjectionEnvironment.moduleFailureHandler
        guard container == nil else {
            failureHandler("The container should not be initialized twice!", file, line)
            return
        }
        
        switch containerOption {
        case .global:
            Self.container = LightInjectionEnvironment.globalDependencyContainer
        case .exclusive:
            Self.container = LightInjectionEnvironment.moduleExclusiveDependencyContainerBuilder()
        case let .custom(customContainer):
            Self.container = customContainer
        }
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
        failureHandler customFailureHandler: ModuleFailureHandler? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        do {
            try container.registerLazyDependency(
                factory: factory,
                forMetaType: metaType
            )
        } catch {
            let failureHandler = customFailureHandler ?? LightInjectionEnvironment.moduleFailureHandler
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
        failureHandler customFailureHandler: ModuleFailureHandler? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        do {
            try container.register(
                instance: instance,
                forMetaType: metaType
            )
        } catch {
            let failureHandler = customFailureHandler ?? LightInjectionEnvironment.moduleFailureHandler
            failureHandler(error.localizedDescription, file, line)
        }
    }
}
