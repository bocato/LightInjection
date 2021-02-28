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
        try ModuleEnvironment.dependencyContainer.registerLazyDependency(
            factory: factory,
            forMetaType: metaType
        )
    } catch {
        ModuleEnvironment.configuratorFailureHandler(error.localizedDescription, file, line)
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
        try  ModuleEnvironment.dependencyContainer.register(
            instance: instance,
            forMetaType: metaType
        )
    } catch {
        ModuleEnvironment.configuratorFailureHandler(error.localizedDescription, file, line)
    }
}
