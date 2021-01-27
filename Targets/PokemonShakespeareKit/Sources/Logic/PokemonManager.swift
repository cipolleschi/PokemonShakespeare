//
//  PokemonManager.swift
//  PokemonShakespeare
//
//  Created by Riccardo Cipolleschi on 23/01/21.
//  Copyright © 2021 tuist.io. All rights reserved.
//

import Foundation
import Combine

struct PokemonManager {
  enum Error: Swift.Error {
    case networkError(Swift.Error)
    case invalidURL(String)
  }

  private var _pokemonNames: () throws -> AnyPublisher<[String], Error>

  private var _sprite: (String) throws -> AnyPublisher<URL?, Error>

  private var _originalArtwork: (String) throws -> AnyPublisher<URL?, Error>

  private var _description: (String) throws -> AnyPublisher<String?, Error>

  func pokemonNames() throws -> AnyPublisher<[String], Error> {
    try self._pokemonNames()
  }

  func sprite(for pokemon: String) throws -> AnyPublisher<URL?, Error> {
    try self._sprite(pokemon)
  }

  func originalArtwork(for pokemon: String) throws -> AnyPublisher<URL?, Error> {
    try self._originalArtwork(pokemon)
  }

  func description(for pokemon: String) throws -> AnyPublisher<String?, Error> {
    try self._description(pokemon)
  }
}

// MARK: - Live Implementation
extension PokemonManager {
  static func live(session: DataTaskPublisherSession = URLSession.shared) -> Self {
    let baseUrl = "https://pokeapi.co/api/v2/"
    var namesCache: [String] = []
    var pokemonCache: [String: Pokemon] = [:]

    return .init {

      guard namesCache.isEmpty else {
        return Deferred { Just(namesCache) }
          .mapError { error in PokemonManager.Error.networkError(error) }
          .eraseToAnyPublisher()
      }


      // 2000 to avoid pagination and be resilient to further pokemon addition
      // the proper approach would be to use pagination and ask for a fixed number of pokemon
      // and query them using the limit and the offset parameters.
      // Given that the pokemon are a finite amount, that the api returns a list where each pokemon is
      // represented with only a couple of field, it is more practical that we ask for all the pokemon
      // in a single call.
      let path = "pokemon?limit=2000"
      let url = URL(string: "\(baseUrl)\(path)")!

      let request = URLRequest(url: url)
      return session
        .anyDataTaskPublisher(for: request)
        .map(\.data)
        .decode(type: PokemonList.self, decoder: JSONDecoder())
        .map { result in
          let names = result.results.map(\.name)
          namesCache = names
          return names
        }
        .mapError(PokemonManager.Error.networkError)
        .eraseToAnyPublisher()

    } _sprite: { pokemon in

      if let cached = pokemonCache[pokemon] {
        return Self.cachedPokemonRepresentation(from: cached, keypath: \.sprites.frontDefault)
      }

      return try pokemonRequest(
        for: pokemon,
        baseUrl: URL(string: baseUrl)!,
        session: session,
        keypath: \.sprites.frontDefault,
        cachingFunction: { pokemonCache[pokemon] = $0 })



    } _originalArtwork: { pokemon in

      if let cached = pokemonCache[pokemon] {
        return Self.cachedPokemonRepresentation(from: cached, keypath: \.sprites.other.officialArtwork.frontDefault)
      }

      return try pokemonRequest(
        for: pokemon,
        baseUrl: URL(string: baseUrl)!,
        session: session,
        keypath: \.sprites.other.officialArtwork.frontDefault,
        cachingFunction: { pokemonCache[pokemon] = $0 })


    } _description: { pokemon in

      let path = "pokemon-species/\(pokemon)"

      let url = URL(string: baseUrl)!.appendingPathComponent(path)

      let request = URLRequest(url: url)

      let decoder = JSONDecoder()
      decoder.keyDecodingStrategy = .convertFromSnakeCase

      return session
        .anyDataTaskPublisher(for: request)
        .map(\.data)
        .decode(type: PokemonSpecies.self, decoder: decoder)
        .map {
          return $0
            .flavorTextEntries
            .first { $0.language.name == "en" }
            .map(\.flavorText)?
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\u{c}", with: " ")
        }
        .mapError(PokemonManager.Error.networkError)
        .eraseToAnyPublisher()
    }
  }

  fileprivate static func cachedPokemonRepresentation(
    from cached: Pokemon,
    keypath: KeyPath<Pokemon, URL?>
  ) -> AnyPublisher<URL?, PokemonManager.Error> {
    return Deferred {
      Just(cached[keyPath: keypath])
    }
    .mapError { error in PokemonManager.Error.networkError(error) }
    .eraseToAnyPublisher()
  }

  fileprivate static func pokemonRequest(
    for pokemon: String,
    baseUrl: URL,
    session: DataTaskPublisherSession,
    keypath: KeyPath<Pokemon, URL?>,
    cachingFunction: @escaping (Pokemon) -> ()
  ) throws -> AnyPublisher<URL?, PokemonManager.Error> {

    let path = "pokemon/\(pokemon)"
    let url = baseUrl.appendingPathComponent(path)

    let request = URLRequest(url: url)

    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase

    return session
      .anyDataTaskPublisher(for: request)
      .map(\.data)
      .decode(type: Pokemon.self, decoder: decoder)
      .map {
        cachingFunction($0)
        return $0[keyPath: keypath]
      }
      .mapError(PokemonManager.Error.networkError)
      .eraseToAnyPublisher()
  }
}

// MARK: Models
extension PokemonManager {
  struct PokemonList: Codable {
    struct Result: Codable {
      let name: String
    }
    let count: Int
    let next: URL?
    let previous: URL?
    let results: [Result]
  }

  struct Pokemon: Codable {

    struct Sprites: Codable {

      struct Other: Codable {
        enum CodingKeys: String, CodingKey {
          case officialArtwork = "official-artwork"
        }

        struct OfficialArtwork: Codable {
          let frontDefault: URL?
        }

        let officialArtwork: OfficialArtwork
      }

      let frontDefault: URL?
      let other: Other
    }

    let sprites: Sprites

  }

  struct PokemonSpecies: Codable {
    struct FlavorTextEntry: Codable {
      struct Language: Codable {
        let name: String
      }
      let flavorText: String
      let language: Language
    }

    let flavorTextEntries: [FlavorTextEntry]
  }
}
