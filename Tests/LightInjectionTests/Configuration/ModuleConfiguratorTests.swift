@testable import LightInjection
import XCTest

final class ModuleConfiguratorTests: XCTestCase {
    // MARK: - Properties

    private let dependencyContainerMock: DependencyContainerMock = .init()
    private let failureHandlerSpy: ModuleConfiguratorFailureHandlerSpy = .init()

    // MARK: - Tests

    func test_registerLazyDependency_shouldStoreInstance_whenRegistrationSucceeds() {
        LightInjection.moduleContainer = dependencyContainerMock

        let factory: LazyDependencyFactory = MyDependency.init
        let metaType = MyDependencyProtocol.self
        let metaTypeName = String(describing: metaType)

        // When
        LightInjection.registerLazyDependency(factory: factory, forMetaType: metaType)

        // Then
        XCTAssertTrue(dependencyContainerMock.registerLazyDependencyCalled)
        XCTAssertEqual(dependencyContainerMock.lazyDependencyMetaTypePassed, metaTypeName)
    }

    func test_registerLazyDependency_shouldCallTheFailureHandler_whenRegistrationFails() {
        // Given
        LightInjection.moduleContainer = dependencyContainerMock
        LightInjection.moduleFailureHandler = failureHandlerSpy.closure

        let factory: LazyDependencyFactory = MyDependency.init
        let metaType = MyDependencyProtocol.self
        let metaTypeName = String(describing: metaType)

        let containerFailure: DependencyContainerFailure = .tryingToRegisterDependencyTwice(metaTypeName)
        dependencyContainerMock.registerLazyDependencyErrorToBeThrown = containerFailure

        // When
        LightInjection.registerLazyDependency(factory: factory, forMetaType: metaType)

        // Then
        XCTAssertTrue(failureHandlerSpy.failureHandlerCalled)
        XCTAssertEqual(failureHandlerSpy.failureMessagePassed, containerFailure.localizedDescription)
    }

    func test_registerInstance_shouldStoreInstance_whenRegistrationSucceeds() {
        // Given
        LightInjection.moduleContainer = dependencyContainerMock

        let instance: MyDependencyProtocol = MyDependency()
        let metaType = MyDependencyProtocol.self
        let metaTypeName = String(describing: metaType)

        // When
        LightInjection.register(instance: instance, forMetaType: metaType)

        // Then
        XCTAssertTrue(dependencyContainerMock.registerInstanceCalled)
        XCTAssertTrue(dependencyContainerMock.instancePassed as? MyDependencyProtocol === instance)
        XCTAssertEqual(dependencyContainerMock.instanceMetaTypePassed, metaTypeName)
    }

    func test_registerInstance_shouldCallTheFailureHandler_whenRegistrationFails() {
        // Given
        LightInjection.moduleContainer = dependencyContainerMock
        LightInjection.moduleFailureHandler = failureHandlerSpy.closure

        let instance: MyDependencyProtocol = MyDependency()
        let metaType = MyDependencyProtocol.self
        let metaTypeName = String(describing: metaType)

        let containerFailure: DependencyContainerFailure = .tryingToRegisterDependencyTwice(metaTypeName)
        dependencyContainerMock.registerInstanceErrorToBeThrown = containerFailure

        // When
        LightInjection.register(instance: instance, forMetaType: metaType)

        // Then
        XCTAssertTrue(failureHandlerSpy.failureHandlerCalled)
        XCTAssertEqual(failureHandlerSpy.failureMessagePassed, containerFailure.localizedDescription)
    }
}

// MARK: - Test Doubles

final class ModuleConfiguratorFailureHandlerSpy {
    private(set) var closure: ModuleConfiguratorFailureHandler = { _, _, _ in }
    private(set) var failureHandlerCalled = false
    private(set) var failureMessagePassed: String = ""
    init() {
        closure = { failureMessage, _, _ in
            self.failureHandlerCalled = true
            self.failureMessagePassed = failureMessage()
        }
    }
}
