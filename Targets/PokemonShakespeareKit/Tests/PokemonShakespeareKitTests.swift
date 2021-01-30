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

  // MARK: - Description
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

  func testDescription_pokemonFails() throws {
    let expectedError = URLError(.unknown)
    var receivedError: KitError? = nil
    let wrongPokemon = "pika"
    let shakespeareKit = PokemonShakespeareKit.live(
      pokemonManager: PokemonManager.live(session: MockedSession.alwaysFailing(expectedError: expectedError)),
      shakespeareTranslator: ShakespeareTranslator.live(session: MockedSession.unimplemented)
    )

    let exp = expectation(description: "Wait for publisher")
    shakespeareKit.description(for: wrongPokemon)
      .sink { completion in
        switch completion {
        case .failure(let error):
          receivedError = error
          exp.fulfill()
        case .finished:
          XCTFail("Should never reach this point")
        }
      } receiveValue: { text in
        XCTFail("Should not receive anything")
      }.store(in: &self.cancellables)

    wait(for: [exp], timeout: 1)
    XCTAssertEqual(receivedError, KitError.pokemonNotFound)

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

  // MARK: - Available Pokemon
  func testAvailablePokemn() throws {
    let names = ["Bulbasaur", "Ivysaur", "Venusaur"]
    var receivedNames: [String]? = nil
    let shakespeareKit = PokemonShakespeareKit.live(
      pokemonManager: PokemonManager.live(session: MockedSession.namesSession(names: names)),
      shakespeareTranslator: ShakespeareTranslator.unimplemented
    )

    let exp = expectation(description: "Wait for publisher")
    try shakespeareKit.availablePokemon()
      .sink { self.handle(completion: $0, exp: exp) } receiveValue: {
        receivedNames = $0
      }
      .store(in: &self.cancellables)
    wait(for: [exp], timeout: 1)
    let unwrappedNames = try XCTUnwrap(receivedNames)
    XCTAssertEqual(names, unwrappedNames)
  }

  func testPokemnSprite() throws {

    let shakespeareKit = PokemonShakespeareKit.live(
      pokemonManager: PokemonManager.live(session: MockedSession.pokemonSession(pokemon: Self.pokemon)),
      shakespeareTranslator: ShakespeareTranslator.unimplemented
    )
    var receivedSpriteURL: URL? = nil
    let exp = expectation(description: "Wait for publisher")
    try shakespeareKit.sprite(for: "Pikachu")
      .sink { self.handle(completion: $0, exp: exp) } receiveValue: {
        receivedSpriteURL = $0
      }
      .store(in: &self.cancellables)
    wait(for: [exp], timeout: 1)
    let unwrappedURL = try XCTUnwrap(receivedSpriteURL)
    XCTAssertEqual(Self.spriteURL, unwrappedURL)
  }

  func testPokemnArtwork() throws {
    let shakespeareKit = PokemonShakespeareKit.live(
      pokemonManager: PokemonManager.live(session: MockedSession.pokemonSession(pokemon: Self.pokemon)),
      shakespeareTranslator: ShakespeareTranslator.unimplemented
    )
    var receivedArtworkURL: URL? = nil
    let exp = expectation(description: "Wait for publisher")
    try shakespeareKit.originalArtwork(for: "Pikachu")
      .sink { self.handle(completion: $0, exp: exp) } receiveValue: {
        receivedArtworkURL = $0
      }
      .store(in: &self.cancellables)
    wait(for: [exp], timeout: 1)
    let unwrappedURL = try XCTUnwrap(receivedArtworkURL)
    XCTAssertEqual(Self.artWorkURL, unwrappedURL)
  }

}

extension PokemonShakespeareKitTests {
  static let spriteURL = URL(string: "https://an.url.com/a-picture.png")!
  static let artWorkURL = URL(string: "https://an.url.com/another-picture.png")!
  static let pokemon = PokemonManager.Pokemon(
    sprites: .init(
      frontDefault: spriteURL,
      other: .init(
        officialArtwork: .init(
          frontDefault: artWorkURL
        )
      )
    )
  )
}
