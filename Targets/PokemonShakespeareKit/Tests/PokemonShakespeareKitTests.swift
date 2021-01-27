//
//  PokemonShakespeareKitTests.swift
//  PokemonShakespeareTests
//
//  Created by Riccardo Cipolleschi on 24/01/21.
//  Copyright © 2021 tuist.io. All rights reserved.
//

import XCTest
import Combine
@testable import PokemonShakespeareKit

class PokemonShakespeareKitTests: XCTestCase {

  var cancellables: Set<AnyCancellable> = []
  override func setUpWithError() throws {
    cancellables = []
  }

  override func tearDownWithError() throws {
    cancellables.forEach { $0.cancel() }
  }

  func test_description() throws {
    let expectedDescription = "At which hour several of these pokémon gather, their electricity couldst buildeth and cause lightning storms."
    var receivedText: String? = nil

    let shakespeareKit = PokemonShakespeareKit.live(
      pokemonManager: PokemonManager.live(session: MockedSession.pokemonDescription(description: expectedDescription)),
      shakespeareTranslator: ShakespeareTranslator.live(session: MockedSession.alwaysSuccessful(expectedResult: expectedDescription))
    )

    let exp = expectation(description: "Wait for publisher")
    shakespeareKit.description(for: "pikachu")
      .sink { self.handle(completion: $0, exp: exp)
      } receiveValue: { text in
        receivedText = text
      }.store(in: &self.cancellables)

    wait(for: [exp], timeout: 10)

    let finalText = try XCTUnwrap(receivedText)
    XCTAssertEqual(finalText, expectedDescription)
  }

  func handle(
    completion: Subscribers.Completion<KitError>,
    exp: XCTestExpectation,
    line: UInt = #line,
    function: StaticString = #function
  ) {
    switch completion {
    case .failure(let error):
      XCTFail("Test should not fail \(error)")
    case .finished:
      exp.fulfill()
    }
  }

}
