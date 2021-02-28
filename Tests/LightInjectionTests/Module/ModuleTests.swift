@testable import LightInjection
import XCTest

final class ModuleTests: XCTestCase {
    // MARK: - Properties

    private let dependencyContainerMock: DependencyContainerMock = .init()
    private let failureHandlerSpy: LightInjectionConfiguratorFailureHandlerSpy = .init()

    // MARK: - Tests
    
    func test_initialize_withoutParametersShouldUseGlobalContainer() {
        // Given
        TestModule.container = nil
        ModuleEnvironment.dependencyContainer = DependencyContainer()
        let globalContainer = ModuleEnvironment.dependencyContainer
        // When
        TestModule.initialize()
        // Then
        XCTAssertTrue(TestModule.container === globalContainer)
    }
    
    func test_initialize_whenTheModuleIsInitializedTwice_itShouldCallTheFailureHandler() {
        // Given
        TestModule.container = nil
        TestModule.initialize()
        // When
        var failureMessageReturned: String?
        TestModule.initialize(
            failureHandler: { message, _, _ in
                failureMessageReturned = message()
            }
        )
        // Then
        XCTAssertEqual(failureMessageReturned, "The container should not be initialized twice!")
    }

    func test_registerLazyDependency_shouldStoreFactory_whenRegistrationSucceeds() {
        // Given
        TestModule.container = nil
        let dependencyContainerMock: DependencyContainerMock = .init()
        TestModule.initialize(withDependenciesContainer: dependencyContainerMock)
        let factory: LazyDependencyFactory = MyDependency.init
        let metaType = MyDependencyProtocol.self
        let metaTypeName = String(describing: metaType)

        // When
        TestModule.registerLazyDependency(factory: factory, forMetaType: metaType)

        // Then
        XCTAssertTrue(dependencyContainerMock.registerLazyDependencyCalled)
        XCTAssertEqual(dependencyContainerMock.lazyDependencyMetaTypePassed, metaTypeName)
    }

    func test_registerLazyDependency_shouldCallTheFailureHandler_whenRegistrationFails() {
        // Given
        TestModule.container = nil

        let factory: LazyDependencyFactory = MyDependency.init
        let metaType = MyDependencyProtocol.self
        let metaTypeName = String(describing: metaType)

        let containerFailure: DependencyContainerFailure = .tryingToRegisterDependencyTwice(metaTypeName)
        dependencyContainerMock.registerLazyDependencyErrorToBeThrown = containerFailure

        TestModule.initialize(
            withDependenciesContainer: dependencyContainerMock,
            failureHandler: failureHandlerSpy.closure
        )

        // When
        TestModule.registerLazyDependency(factory: factory, forMetaType: metaType)

        // Then
        XCTAssertTrue(failureHandlerSpy.failureHandlerCalled)
        XCTAssertEqual(failureHandlerSpy.failureMessagePassed, containerFailure.localizedDescription)
    }

    func test_registerInstance_shouldStoreInstance_whenRegistrationSucceeds() {
        // Given
        TestModule.container = nil
        let dependencyContainerMock: DependencyContainerMock = .init()
        TestModule.initialize(withDependenciesContainer: dependencyContainerMock)
        let instance: MyDependencyProtocol = MyDependency()
        let metaType = MyDependencyProtocol.self
        let metaTypeName = String(describing: metaType)

        // When
        TestModule.register(instance: instance, forMetaType: metaType)

        // Then
        XCTAssertTrue(dependencyContainerMock.registerInstanceCalled)
        XCTAssertTrue(dependencyContainerMock.instancePassed as? MyDependencyProtocol === instance)
        XCTAssertEqual(dependencyContainerMock.instanceMetaTypePassed, metaTypeName)
    }

    func test_registerInstance_shouldCallTheFailureHandler_whenRegistrationFails() {
        // Given
        TestModule.container = nil

        let instance: MyDependencyProtocol = MyDependency()
        let metaType = MyDependencyProtocol.self
        let metaTypeName = String(describing: metaType)

        let containerFailure: DependencyContainerFailure = .tryingToRegisterDependencyTwice(metaTypeName)
        dependencyContainerMock.registerInstanceErrorToBeThrown = containerFailure

        TestModule.initialize(
            withDependenciesContainer: dependencyContainerMock,
            failureHandler: failureHandlerSpy.closure
        )

        // When
        TestModule.register(instance: instance, forMetaType: metaType)

        // Then
        XCTAssertTrue(failureHandlerSpy.failureHandlerCalled)
        XCTAssertEqual(failureHandlerSpy.failureMessagePassed, containerFailure.localizedDescription)
    }
}

// MARK: - Test Doubles

extension ModuleTests {
    enum TestModule: Module {
        static var container: DependencyContainerInterface!
        static var failureHandler: ModuleFailureHandler!
    }
}

final class ModuleFailureHandlerSpy {
    private(set) var closure: ModuleFailureHandler = { _, _, _ in }
    private(set) var failureHandlerCalled = false
    private(set) var failureMessagePassed: String = ""
    init() {
        closure = { failureMessage, _, _  in
            self.failureHandlerCalled = true
            self.failureMessagePassed = failureMessage()
        }
    }
}
