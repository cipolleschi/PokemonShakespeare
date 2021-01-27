//
//  ShakespeareTranslator.swift
//  PokemonShakespeareTests
//
//  Created by Riccardo Cipolleschi on 23/01/21.
//  Copyright © 2021 tuist.io. All rights reserved.
//

import XCTest
import Combine
@testable import PokemonShakespeareKit

class ShakespeareTranslatorTest: XCTestCase {

  var cancellables: Set<AnyCancellable> = []

  override func setUpWithError() throws {
    cancellables = []
  }

  override func tearDownWithError() throws {
    cancellables.forEach { $0.cancel() }
  }

  func test_success() throws {
    let expectedResult = "This is a translation"
    var obtainedResult: String? = nil
    let exp = expectation(description: "Wait for network request")
    try ShakespeareTranslator.live(session: MockedSession.alwaysSuccessful(expectedResult: expectedResult))
      .translation(for: expectedResult)
      .sink { self.handle(completion: $0, exp: exp) } receiveValue: {
        obtainedResult = $0
      }.store(in: &cancellables)
    wait(for: [exp], timeout: 10)
    // Assert
    let unwrappedReceived = try XCTUnwrap(obtainedResult)
    XCTAssertEqual(unwrappedReceived, expectedResult)
  }

  func test_failure() throws {
    let expectedError: URLError = URLError(URLError.Code.badURL)
    var obtainedResult: ShakespeareTranslator.Error? = nil
    let exp = expectation(description: "Wait for network request")
    try ShakespeareTranslator.live(session: MockedSession.alwaysFailing(expectedError: expectedError))
      .translation(for: "This is a translation")
      .sink { completion in
        switch completion {
        case .failure(let error):
          obtainedResult = error
          exp.fulfill()
        case .finished:
          break
        }

      } receiveValue: { _ in
        XCTFail("This should never be called")
      }.store(in: &cancellables)
    wait(for: [exp], timeout: 10)
    // Assert
    let unwrappedReceived = try XCTUnwrap(obtainedResult)
    switch unwrappedReceived {
    case .invalidQueryText:
      XCTFail("Should receive a network error")
    case .invalidURL:
      XCTFail("Should receive a network error")
    case .networkError(let error):
      guard let urlError = error as? URLError else {
        XCTFail("Wrong error type")
        return
      }
      XCTAssertEqual(urlError, expectedError)
    }
  }

  // Integration tests are used to chekc that the code can actually invoke the service
  // This can be moved to its own suite. For sake of simplicity, we can keep it here
  func test_happyPath_integration() throws {

    // Arrange
    let query = "You gave Mr. Tim a hearty meal, but unfortunately what he ate made him die."
    let expected = "Thee did giveth mr. Tim a hearty meal,  but unfortunately what he did doth englut did maketh him kicketh the bucket."
    var received: String? = nil
    let exp = expectation(description: "Wait for network request")

    // Act
    try ShakespeareTranslator.live().translation(for: query)
      .sink(receiveCompletion: { self.handle(completion: $0, exp: exp) }) {
        received = $0
      }
      .store(in: &cancellables)

    wait(for: [exp], timeout: 10)

    // Assert
    let unwrappedReceived = try XCTUnwrap(received)
    XCTAssertEqual(unwrappedReceived, expected)
  }

  // MARK: Helper
  func handle(
    completion: Subscribers.Completion<ShakespeareTranslator.Error>,
    exp: XCTestExpectation,
    line: UInt = #line,
    function: StaticString = #function
  ) {
    switch completion {
    case .failure(let error):
      XCTFail("Error received: \(error)", line: line)
    case .finished:
      exp.fulfill()
    }
  }
}

// MARK: - Mocks

extension MockedSession {
  static func alwaysSuccessful(expectedResult: String) -> Self {
    let toRet = ShakespeareTranslator.FuntranslationResult(
      success: .init(total: 1),
      contents: .init(translated: expectedResult, text: expectedResult, translation: "shakespeare")
    )

    return Self { _ in
      return Deferred {
        Just((data: try! JSONEncoder().encode(toRet), response: URLResponse()))
      }
      .mapError { _ in URLError(.unknown)} // mapping Never will never be executed. This is required to match the signatures
      .eraseToAnyPublisher()
    }
  }

  static func alwaysFailing(expectedError: URLError) -> Self {
    return Self { _ in
      return Deferred {
        Just((data: "This should never be read".data(using: .utf8), response: URLResponse()))
      }
      .tryMap { _ in throw expectedError}
      .mapError { $0 as! URLError }
      .eraseToAnyPublisher()
    }
  }
}
