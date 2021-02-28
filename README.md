# LightInjection

## Installation
You can add ComposableArchitecture to an Xcode project by adding it as a package dependency.

  1. From the **File** menu, select **Swift Packages › Add Package Dependency…**
  2. Enter "https://github.com/bocato/LightInjection" into the package repository URL text field
  3. Depending on how your project is structured:
      - If you have a single application target that needs access to the library, then add **LightInjection** directly to your application.
      - If you want to use this library from multiple targets you must create a shared framework that depends on **ComposableArchitecture** and then depend on that framework in all of your targets.

## Basic Usage (to be improved)
```swift
protocol MyDependencyProtocol {}
final class MyDependency: MyDependencyProtocol {}

protocol MyLazyDependencyProtocol {}
final class MyLazyDependency: MyLazyDependencyProtocol {}

protocol ContainerSpecificDependency {}
final class MyModuleSpecificDependency: ContainerSpecificDependencyProtocol {}

enum MyModule: Module {
    static var container: DependencyContainerInterface!
    static var failureHandler: ModuleFailureHandler!
}

protocol ModuleSpecificDependencyProtocol {}
final class ModuleSpecificDependency: ModuleSpecificDependencyProtocol {}

final class MyVeryOwnDependenciesContainer: DependencyContainerInterface {
    // My very own implementation conforming to `DependencyContainerInterface`... 
    // ...
    static let shared = MyVeryOwnDependenciesContainer()
    // ...
}

final class ViewModel {
    @Dependency var myDependency: MyDependencyProtocol
    @Dependency var myLazyDependency: MyLazyDependencyProtocol
    @Dependency(resolver: MyVeryOwnDependenciesContainer.shared) var containerSpecificDependency: ContainerSpecificDependencyProtocol
    @Dependency(ownedBy: MyModule.self) var moduleSpecificDependency: ModuleSpecificDependencyProtocol
    
    init( // If you want to initialize them by hand, without calling the container... Interesting for tests.
        myDependency: MyDependencyProtocol,
        myLazyDependency: MyLazyDependencyProtocol,
        containerSpecificDependency: ContainerSpecificDependencyProtocol,
        moduleSpecificDependency: ModuleSpecificDependencyProtocol
    ) {
        self._myDependency = .resolved(myDependency)
        self._myLazyDependency = .resolved(myLazyDependency)
        self._containerSpecificDependency = .resolved(containerSpecificDependency)
        self._moduleSpecificDependency = .resolved(moduleSpecificDependency)
    }
}

// Global Container Setups
LightInjection.register(
    instance: MyDependency(),
    forMetaType: MyDependencyProtocol.self
)
LightInjection.registerLazyDependency(
    factory: MyLazyDependency.init,
    forMetaType: MyLazyDependencyProtocol.self
)

// Module Setups
MyModule.initialize()
MyModule.register(
    instance: MyModuleSpecificDependency(),
    forMetaType: MyModuleSpecificDependencyProtocol.self
)
```

## // TODO: Improve DOCS...
