//
//  PokemonManagerTests.swift
//  PokemonShakespeareKitTests
//
//  Created by Riccardo Cipolleschi on 23/01/21.
//  Copyright © 2021 tuist.io. All rights reserved.
//

import Foundation
import XCTest
import Combine
@testable import PokemonShakespeareKit

class PokemonManagerTests: XCTestCase {
  var cancellables: Set<AnyCancellable> = []

  override func setUpWithError() throws {
    cancellables = []
  }

  override func tearDownWithError() throws {
    cancellables.forEach { $0.cancel() }
  }

  // MARK: - Test Sprite
  func test_sprite_is_returned() throws {
    let urlString1 = "https://pokeapi.co/"
    let urlString2 = "https://pokeapi.co2/"

    let pokemon = PokemonManager.Pokemon(
      sprites: .init(
        frontDefault: URL(string: urlString1),
        other: .init(
          officialArtwork: .init(frontDefault: URL(string: urlString2))
        )
      )
    )
    var receivedURL: URL? = nil

    let exp = expectation(description: "wait for network request")
    PokemonManager.live(session: MockedSession.pokemonSession(pokemon: pokemon))
      .sprite(for: "pikachu")
      .sink {
        self.handle(completion: $0, exp: exp)
      } receiveValue: { result in
        receivedURL = result
      }.store(in: &self.cancellables)

    wait(for: [exp], timeout: 10)
    XCTAssertEqual(receivedURL?.absoluteString, urlString1)
  }

  func test_pokemon_is_cached_when_sprite_is_invoked() throws {
    let urlString1 = "https://pokeapi.co/"
    let urlString2 = "https://pokeapi.co2/"

    let pokemon = PokemonManager.Pokemon(
      sprites: .init(
        frontDefault: URL(string: urlString1),
        other: .init(
          officialArtwork: .init(frontDefault: URL(string: urlString2))
        )
      )
    )

    let session = MockedSession.secondCallFailing(from: MockedSession.pokemonSession(pokemon: pokemon))
    let pokemonManager = PokemonManager.live(session: session)

    var receivedURL: URL? = nil

    let exp = expectation(description: "wait for network request")
    pokemonManager
      .sprite(for: "pikachu")
      .sink {
        self.handle(completion: $0, exp: exp)
      } receiveValue: { result in
        receivedURL = result
      }.store(in: &self.cancellables)

    wait(for: [exp], timeout: 10)
    XCTAssertEqual(receivedURL?.absoluteString, urlString1)

    let exp2 = expectation(description: "wait for network request")
    pokemonManager
      .originalArtwork(for: "pikachu")
      .sink {
        self.handle(completion: $0, exp: exp2)
      } receiveValue: { result in
        receivedURL = result
      }.store(in: &self.cancellables)

    wait(for: [exp2], timeout: 10)
    XCTAssertEqual(receivedURL?.absoluteString, urlString2)
  }

  // MARK: Test Artwork
  func test_artwork_is_returned() throws {
    let urlString1 = "https://pokeapi.co/"
    let urlString2 = "https://pokeapi.co2/"

    let pokemon = PokemonManager.Pokemon(
      sprites: .init(
        frontDefault: URL(string: urlString1),
        other: .init(
          officialArtwork: .init(frontDefault: URL(string: urlString2))
        )
      )
    )
    var receivedURL: URL? = nil

    let exp = expectation(description: "wait for network request")
    PokemonManager.live(session: MockedSession.pokemonSession(pokemon: pokemon))
      .originalArtwork(for: "pikachu")
      .sink {
        self.handle(completion: $0, exp: exp)
      } receiveValue: { result in
        receivedURL = result
      }.store(in: &self.cancellables)

    wait(for: [exp], timeout: 10)
    XCTAssertEqual(receivedURL?.absoluteString, urlString2)
  }

  func test_pokemon_is_cached_when_artwork_is_invoked() throws {
    let urlString1 = "https://pokeapi.co/"
    let urlString2 = "https://pokeapi.co2/"

    let pokemon = PokemonManager.Pokemon(
      sprites: .init(
        frontDefault: URL(string: urlString1),
        other: .init(
          officialArtwork: .init(frontDefault: URL(string: urlString2))
        )
      )
    )

    let session = MockedSession.secondCallFailing(from: MockedSession.pokemonSession(pokemon: pokemon))
    let pokemonManager = PokemonManager.live(session: session)

    var receivedURL: URL? = nil

    let exp = expectation(description: "wait for network request")
    pokemonManager
      .originalArtwork(for: "pikachu")
      .sink {
        self.handle(completion: $0, exp: exp)
      } receiveValue: { result in
        receivedURL = result
      }.store(in: &self.cancellables)

    wait(for: [exp], timeout: 10)
    XCTAssertEqual(receivedURL?.absoluteString, urlString2)

    let exp2 = expectation(description: "wait for network request")
    pokemonManager
      .sprite(for: "pikachu")
      .sink {
        self.handle(completion: $0, exp: exp2)
      } receiveValue: { result in
        receivedURL = result
      }.store(in: &self.cancellables)

    wait(for: [exp2], timeout: 10)
    XCTAssertEqual(receivedURL?.absoluteString, urlString1)
  }

  // MARK: test_description
  func test_description() throws {
    let description = "When several of these POKéMON gather, their electricity could build and cause lightning storms."
    var receivedText: String? = nil

    let exp = expectation(description: "wait for network request")
    PokemonManager.live(session: MockedSession.pokemonDescription(description: description))
      .description(for: "pikachu")
      .sink {
        self.handle(completion: $0, exp: exp)
      } receiveValue: { result in
        receivedText = result
      }.store(in: &self.cancellables)

    wait(for: [exp], timeout: 10)
    XCTAssertEqual(receivedText, description)
  }

  // MARK: - Integration
  func test_sprite_integration() throws {
    let expectedPath = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/12.png"
    var receivedURL: URL? = nil
    let exp = expectation(description: "wait for network request")
    PokemonManager.live()
      .sprite(for: "butterfree")
      .sink {
        self.handle(completion: $0, exp: exp)
      } receiveValue: { url in
        receivedURL = url
      }.store(in: &self.cancellables)

    wait(for: [exp], timeout: 10)

    let finalURL = try XCTUnwrap(receivedURL)
    XCTAssertEqual(finalURL.absoluteString, expectedPath)
  }

  func test_artwork_integration() throws {
    let expectedPath = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/12.png"
    var receivedURL: URL? = nil

    let exp = expectation(description: "wait for network request")
    PokemonManager.live()
      .originalArtwork(for: "butterfree")
      .sink {
        self.handle(completion: $0, exp: exp)
      } receiveValue: { url in
        receivedURL = url
      }.store(in: &self.cancellables)

    wait(for: [exp], timeout: 10)

    let finalURL = try XCTUnwrap(receivedURL)
    XCTAssertEqual(finalURL.absoluteString, expectedPath)
  }

  func test_description_integration() throws {
    let expectedResult = """
    Spits fire that is hot enough to melt boulders. Known to cause forest fires unintentionally.
    """
    var receivedText: String? = nil

    let exp = expectation(description: "wait for network request")
    PokemonManager.live()
      .description(for: "charizard")
      .sink {
        self.handle(completion: $0, exp: exp)
      } receiveValue: { text in
        receivedText = text
      }.store(in: &self.cancellables)

    wait(for: [exp], timeout: 10)
    
    let finalText = try XCTUnwrap(receivedText)
    XCTAssertEqual(finalText, expectedResult)
  }

  fileprivate func handle(
    completion: Subscribers.Completion<PokemonManager.Error>,
    exp: XCTestExpectation,
    line: UInt = #line,
    function: StaticString = #function
  ) {
    switch completion {
    case .failure:
      XCTFail("Should not fail", line: line)
    case .finished:
      exp.fulfill()
    }
  }
}

extension MockedSession {
  static func namesSession(names: [String]) -> Self {
    let pokemonList = PokemonManager.PokemonList(
      count: 3,
      next: nil,
      previous: nil,
      results: names.map { PokemonManager.PokemonList.Result.init(name: $0) }
    )

    return MockedSession { _ in
      return Just((try! JSONEncoder().encode(pokemonList), URLResponse()))
        .mapError { _ in URLError(.unknown)}
      .eraseToAnyPublisher()

    }
  }

  static func pokemonSession(pokemon: PokemonManager.Pokemon) -> Self {
    return MockedSession { _ in
      let encoder = JSONEncoder()
      encoder.keyEncodingStrategy = .convertToSnakeCase
      return Just((try! encoder.encode(pokemon), URLResponse()))
        .mapError { _ in URLError(.unknown)}
        .eraseToAnyPublisher()

    }
  }

  static func pokemonDescription(description: String) -> Self {
    let pokemonSpecies = PokemonManager.PokemonSpecies(
      flavorTextEntries: [.init(flavorText: description, language: .init(name: "en"))]
    )
    return MockedSession { _ in
      let encoder = JSONEncoder()
      encoder.keyEncodingStrategy = .convertToSnakeCase
      return Just((try! encoder.encode(pokemonSpecies), URLResponse()))
        .mapError { error in
          print(error)
          URLError(.unknown)

        }
        .eraseToAnyPublisher()
    }
  }

  static func secondCallFailing(from mockedSession: MockedSession) -> Self {
    var alreadyRunOnce = false
    return Self { request in
      guard !alreadyRunOnce else {
        fatalError("This session fails the second time is used")
      }
      alreadyRunOnce = true
      return mockedSession.anyDataTaskPublisher(for: request)
    }
  }

}
