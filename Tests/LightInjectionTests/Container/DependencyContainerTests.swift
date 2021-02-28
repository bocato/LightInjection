@testable import LightInjection
import XCTest

final class DependencyContainerTests: XCTestCase {
    // MARK: - Properties

    private let sut: DependencyContainer = .init()

    // MARK: - Tests

    func test_registerLazyDependency_shouldRegisterAFactoryForTheDependency() {
        // Given
        let factory: LazyDependencyFactory = { MyDependency() }
        let metaType = MyDependencyProtocol.self
        // When
        XCTAssertNoThrow(
            try sut.registerLazyDependency(factory: factory, forMetaType: metaType)
        )
        // Then
        let dependencyKey = String(describing: metaType)
        XCTAssertNotNil(sut.lazyDependencyFactories[dependencyKey])
    }

    func test_registerLazyDependency_shouldThrowError_whenRegisteringADependencyTwice() {
        // Given
        let factory: LazyDependencyFactory = { MyDependency() }
        let metaType = MyDependencyProtocol.self
        let dependencyKey = String(describing: metaType)
        // When
        var errorReturned: DependencyContainerFailure?
        do {
            try sut.registerLazyDependency(factory: factory, forMetaType: metaType)
            try sut.registerLazyDependency(factory: factory, forMetaType: metaType)
        } catch {
            errorReturned = error as? DependencyContainerFailure
        }
        // Then
        guard case .tryingToRegisterDependencyTwice(dependencyKey) = errorReturned else {
            XCTFail("Expected .tryingToRegisterDependencyTwice, but got \(String(describing: errorReturned)).")
            return
        }
        XCTAssertNotNil(errorReturned?.errorDescription)
    }

    func test_registerInstance_shouldStoreTheProvidedInstance() {
        // Given
        let instance: MyDependency = .init()
        let metaType = MyDependencyProtocol.self
        // When
        XCTAssertNoThrow(
            try sut.register(instance: instance, forMetaType: metaType)
        )
        // Then
        let dependencyKey = String(describing: metaType)
        XCTAssertNotNil(sut.persistentDependencyInstances[dependencyKey])
    }

    func test_registerInstance_shouldThrowError_whenRegisteringADependencyTwice() {
        // Given
        let instance: MyDependency = .init()
        let metaType = MyDependencyProtocol.self
        let dependencyKey = String(describing: metaType)
        sut.persistentDependencyInstances[dependencyKey] = instance
        // When
        var errorReturned: DependencyContainerFailure?
        do {
            try sut.register(instance: instance, forMetaType: metaType)
        } catch {
            errorReturned = error as? DependencyContainerFailure
        }
        // Then
        guard case .tryingToRegisterDependencyTwice(dependencyKey) = errorReturned else {
            XCTFail("Expected .tryingToRegisterDependencyTwice, but got \(String(describing: errorReturned)).")
            return
        }
        XCTAssertNotNil(errorReturned?.errorDescription)
    }

    func test_get_shouldThrowError_whenTryingToResolveAnUnregisteredDependency() {
        // Given
        let metaType = MyDependencyProtocol.self
        let dependencyKey = String(describing: metaType)
        // When
        var errorReturned: DependencyContainerFailure?
        do {
            _ = try sut.get(metaType)
        } catch {
            errorReturned = error as? DependencyContainerFailure
        }
        // Then
        guard case .couldNotFindProviderForDependency(dependencyKey) = errorReturned else {
            XCTFail("Expected .couldNotFindProviderForDependency, but got \(String(describing: errorReturned)).")
            return
        }
        XCTAssertNotNil(errorReturned?.errorDescription)
    }

    func test_get_shouldReturnAValidDependency_whenTryingToResolveAPreviouslyRegisteredInstance() {
        // Given
        let metaType = MyDependencyProtocol.self
        XCTAssertNoThrow(
            try sut.register(instance: MyDependency(), forMetaType: metaType)
        )
        // When
        let returnedInstance = try? sut.get(metaType)
        // Then
        XCTAssertNotNil(returnedInstance)
    }

    func test_get_shouldStoreInstance_whenResolvingALazyInstanceForTheFirstTime() {
        // Given
        let factory: LazyDependencyFactory = MyDependency.init
        let metaType = MyDependencyProtocol.self
        XCTAssertNoThrow(
            try sut.registerLazyDependency(factory: factory, forMetaType: metaType)
        )
        sut.lazyDependencyInstances.removeAllObjects()
        // When
        let instanceReturned = try? sut.get(metaType)
        // Then
        XCTAssertNotNil(instanceReturned)
        XCTAssertEqual(sut.lazyDependencyInstances.count, 1)
    }

    func test_get_shouldGetInstanceFromStorage_whenResolvingALazyInstanceForTheSecondTime() {
        // Given
        let factory: LazyDependencyFactory = MyDependency.init
        let metaType = MyDependencyProtocol.self
        sut.lazyDependencyInstances = NSMapTable<NSString, LazyDependencyWrapper>(
            keyOptions: .strongMemory,
            valueOptions: .strongMemory
        )
        XCTAssertNoThrow(
            try sut.registerLazyDependency(factory: factory, forMetaType: metaType)
        )
        // When
        XCTAssertEqual(sut.lazyDependencyInstances.count, 0)

        _ = try? sut.get(metaType)
        XCTAssertEqual(sut.lazyDependencyInstances.count, 1)

        let instanceReturned = try? sut.get(metaType)

        // Then
        XCTAssertNotNil(instanceReturned)
    }
}

// MARK: - Stuff

protocol MyDependencyProtocol: AnyObject {}
final class MyDependency: MyDependencyProtocol {}
