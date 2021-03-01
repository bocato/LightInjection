import Foundation

// Defines the module environment, to hold it's dependencies
// See: https://www.pointfree.co/collections/dependencies
var LightInjectionEnvironment: Environment = .live

struct Environment {
    var globalDependencyContainer: DependencyContainerInterface
    var libraryConfiguratorFailureHandler: LightInjectionConfiguratorFailureHandler
    var moduleExclusiveDependencyContainerBuilder: () -> DependencyContainerInterface
    var moduleFailureHandler: ModuleFailureHandler
}
extension Environment {
    static let live: Self = .init(
        globalDependencyContainer:  DependencyContainer.global,
        libraryConfiguratorFailureHandler: { message, file, line in
            fatalError(
                message(),
                file: file,
                line: line
            )
        },
        moduleExclusiveDependencyContainerBuilder: DependencyContainer.init,
        moduleFailureHandler: { message, file, line in
            fatalError(
                message(),
                file: file,
                line: line
            )
        }
    )
}
