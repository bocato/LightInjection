import Foundation

/// Defines typed failures for a dependency  container
public enum DependencyContainerFailure: Error, LocalizedError {
    case tryingToRegisterDependencyTwice(String)
    case couldNotFindProviderForDependency(String)
}

extension DependencyContainerFailure {
    public var errorDescription: String? {
        switch self {
        case let .tryingToRegisterDependencyTwice(name):
            return "Trying to register `\(name)` twice!"
        case let .couldNotFindProviderForDependency(name):
            return "There are no factories or instances registered for `\(name)`!"
        }
    }
}
