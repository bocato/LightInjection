@testable import LightInjection
import XCTest

final class DependencyTests: XCTestCase {
    // MARK: - Properties

    private let dependencyContainerMock: DependencyContainerMock = .init()

    // MARK: - Tests

    func test_convenienceInitWithoutParameters_shouldUseGlobalContainer() {
        // Given
        let sut: Dependency<MyDependencyProtocol>
        // When
        sut = .init()
        // Then
        XCTAssertTrue(sut.container === DependencyContainer.global)
    }

    func test_convenienceInitPassingResolver_shouldSetItAsTheContainer() {
        // Given
        let resolver: DependencyContainer = .init()
        // When
        let sut: Dependency<MyDependencyProtocol> = .init(resolver: resolver)
        // Then
        XCTAssertTrue(sut.container === resolver)
    }

    func test_resolved_shouldSetResolvedValue_andUseGlobalContainer() {
        // Given
        let instance: MyDependencyProtocol = MyDependency()
        // When
        let sut: Dependency<MyDependencyProtocol> = .resolved(instance)
        // Then
        XCTAssertTrue(sut.wrappedValue === instance)
        XCTAssertTrue(sut.container === DependencyContainer.global)
    }

    func test_dependencyCannotBeResolvedTwice() {
        // Given
        let instance: MyDependencyProtocol = MyDependency()
        let failureHandlerSpy: DependencyResolverFailureHandlerSpy = .init()
        let sut: Dependency<MyDependencyProtocol> = .init(
            resolvedValue: instance,
            resolver: dependencyContainerMock,
            failureHandler: failureHandlerSpy.closure
        )
        let instanceTypeName = String(describing: MyDependencyProtocol.self)

        // When
        _ = sut.wrappedValue

        // Then
        XCTAssertTrue(failureHandlerSpy.failureHandlerCalled)
        XCTAssertEqual(failureHandlerSpy.argPassed, "Attempted to resolve \(instanceTypeName) twice!")
    }

    func test_whenTheDependencyIsRegisteredOnTheContainner_itShouldBeResolved() {
        // Given
        let dependencyContainerMock: DependencyContainerMock = .init()
        let sut: Dependency<MyDependencyProtocol> = .init(resolver: dependencyContainerMock)

        let instance: MyDependencyProtocol = MyDependency()
        dependencyContainerMock.getValueToBeReturned = instance

        // When
        let instanceReturned = sut.wrappedValue

        // Then
        XCTAssertTrue(instanceReturned === instance)
    }

    func test_whenTheDependencyIsNotOnTheContainner_itShouldCallTheFailureHandler() {
        // Given
        let dependencyContainerMock: DependencyContainerMock = .init()
        let failureHandlerSpy: DependencyResolverFailureHandlerSpy = .init()
        let sut: Dependency<MyDependencyProtocol> = .init(
            resolvedValue: nil,
            resolver: dependencyContainerMock,
            failureHandler: failureHandlerSpy.closure
        )

        let instanceTypeName = String(describing: MyDependencyProtocol.self)
        dependencyContainerMock.getErrorToBeThrown = .couldNotFindProviderForDependency(instanceTypeName)

        // When
        _ = sut.wrappedValue

        // Then
        XCTAssertTrue(failureHandlerSpy.failureHandlerCalled)
    }
}

// MARK: - Test Doubles

final class DependencyContainerMock: DependencyContainerInterface {
    var getValueToBeReturned: Any?
    var getErrorToBeThrown: DependencyContainerFailure = .couldNotFindProviderForDependency("Mock")
    private(set) var getCallCount = 0
    var getCalled: Bool { getCallCount > 0 }
    private(set) var argPassed: String?
    func get<T>(_ arg: T.Type) throws -> T {
        getCallCount += 1
        argPassed = String(describing: arg)
        if let valueToBeReturned = getValueToBeReturned as? T {
            return valueToBeReturned
        } else {
            throw getErrorToBeThrown
        }
    }

    var registerLazyDependencyErrorToBeThrown: DependencyContainerFailure?
    private(set) var registerLazyDependencyCallCount = 0
    var registerLazyDependencyCalled: Bool { registerLazyDependencyCallCount > 0 }
    private(set) var lazyDependencyFactoryPassed: LazyDependencyFactory?
    private(set) var lazyDependencyMetaTypePassed: String?
    func registerLazyDependency<T>(factory: @escaping LazyDependencyFactory, forMetaType metaType: T.Type) throws {
        registerLazyDependencyCallCount += 1
        lazyDependencyFactoryPassed = factory
        lazyDependencyMetaTypePassed = String(describing: metaType)
        if let errorToThrow = registerLazyDependencyErrorToBeThrown {
            throw errorToThrow
        }
    }

    var registerInstanceErrorToBeThrown: DependencyContainerFailure?
    private(set) var registerInstanceCallCount = 0
    var registerInstanceCalled: Bool { registerInstanceCallCount > 0 }
    private(set) var instancePassed: Any?
    private(set) var instanceMetaTypePassed: String?
    func register<T>(instance: T, forMetaType metaType: T.Type) throws {
        registerInstanceCallCount += 1
        instancePassed = instance
        instanceMetaTypePassed = String(describing: metaType)
        if let errorToThrow = registerInstanceErrorToBeThrown {
            throw errorToThrow
        }
    }
}

final class DependencyResolverFailureHandlerSpy {
    private(set) var closure: DependencyResolverFailureHandler = { _ in }
    private(set) var failureHandlerCalled = false
    private(set) var argPassed: String = ""
    init() {
        closure = { arg in
            self.failureHandlerCalled = true
            self.argPassed = arg
        }
    }
}
