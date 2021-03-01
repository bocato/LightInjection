import Foundation

/// Defines the failure handler for the module configurator
public typealias LightInjectionConfiguratorFailureHandler = (@autoclosure () -> String, StaticString, UInt) -> Void

/// Registers a Lazy Dependency on the global container.
/// - Parameters:
///   - factory: a factory for the  dependency
///   - metaType: the dependency metatype, or it's interface / contract
///   - file: the file that called this function
///   - line: the line of the file that called this function
public func registerLazyDependency<T>(
    factory: @escaping LazyDependencyFactory,
    forMetaType metaType: T.Type,
    file: StaticString = #file,
    line: UInt = #line
) {
    do {
        try LightInjectionEnvironment.globalDependencyContainer.registerLazyDependency(
            factory: factory,
            forMetaType: metaType
        )
    } catch {
        LightInjectionEnvironment.libraryConfiguratorFailureHandler(error.localizedDescription, file, line)
    }
}

/// Registers a Dependency Instance on the global container.
/// - Parameters:
///   - instance: the dependency isntance
///   - metaType: the dependency metatype, or it's interface / contract
///   - file: the file that called this function
///   - line: the line of the file that called this function
public func register<T>(
    instance: T,
    forMetaType metaType: T.Type,
    file: StaticString = #file,
    line: UInt = #line
) {
    do {
        try  LightInjectionEnvironment.globalDependencyContainer.register(
            instance: instance,
            forMetaType: metaType
        )
    } catch {
        LightInjectionEnvironment.libraryConfiguratorFailureHandler(error.localizedDescription, file, line)
    }
}
