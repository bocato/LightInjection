import Foundation

// Defines the module environment, to hold it's dependencies
// See: https://www.pointfree.co/collections/dependencies
var ModuleEnvironment: Environment = .live

struct Environment {
    var dependencyContainer: DependencyContainerInterface
    var configuratorFailureHandler: LightInjectionConfiguratorFailureHandler
    var moduleFailureHandler: ModuleFailureHandler
}
extension Environment {
    static let live: Self = .init(
        dependencyContainer:  DependencyContainer.global,
        configuratorFailureHandler: { message, file, line in
            fatalError(
                message(),
                file: file,
                line: line
            )
        },
        moduleFailureHandler: { message, file, line in
            fatalError(
                message(),
                file: file,
                line: line
            )
        }
    )
}
