import Foundation

/// Defines a wrapper for a dependency, to be able to store dependencies that are not classes.
final class LazyDependencyWrapper {
    let instance: Any
    init(instance: Any) {
        self.instance = instance
    }
}

/// The concrete implementation of a dependency store
public final class DependencyContainer: DependencyContainerInterface {
    // MARK: - Properties

    var lazyDependencyFactories = [String: LazyDependencyFactory]()
    var lazyDependencyInstances = NSMapTable<NSString, LazyDependencyWrapper>(
        keyOptions: .strongMemory,
        valueOptions: .weakMemory
    )
    var persistentDependencyInstances = [String: Any]()

    // MARK: - Singleton

    public static let global = DependencyContainer()

    // MARK: - Initialization

    public init() {}

    // MARK: - Public API

    public func registerLazyDependency<T>(
        factory: @escaping LazyDependencyFactory,
        forMetaType metaType: T.Type
    ) throws {
        let name = String(describing: metaType)
        guard lazyDependencyFactories[name] == nil else {
            throw DependencyContainerFailure.tryingToRegisterDependencyTwice(name)
        }
        lazyDependencyFactories[name] = factory
    }

    public func register<T>(
        instance: T,
        forMetaType metaType: T.Type
    ) throws {
        let name = String(describing: metaType)
        guard persistentDependencyInstances[name] == nil else {
            throw DependencyContainerFailure.tryingToRegisterDependencyTwice(name)
        }
        persistentDependencyInstances[name] = instance
    }

    public func get<T>(_ arg: T.Type) throws -> T {
        let key = String(describing: arg)
        if let persistentDependencyInstance = persistentDependencyInstances[key] as? T {
            return persistentDependencyInstance
        } else {
            return try getLazyInstance(for: T.self, key: key)
        }
    }

    // MARK: - Private Methods

    private func getLazyInstance<T>(for _: T.Type, key: String) throws -> T {
        let objectKey = key as NSString

        if let instanceInMemory = lazyDependencyInstances.object(forKey: objectKey)?.instance as? T {
            return instanceInMemory
        }

        guard
            let factory: LazyDependencyFactory = lazyDependencyFactories[key],
            let newInstance = factory() as? T
        else { throw DependencyContainerFailure.couldNotFindProviderForDependency(key) }

        let wrappedInstance = LazyDependencyWrapper(instance: newInstance)
        lazyDependencyInstances.setObject(wrappedInstance, forKey: objectKey)

        return newInstance
    }
}
