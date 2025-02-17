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
    case networkError(URLError)
    case invalidURL(String)
  }

  private var _sprite: (String) -> AnyPublisher<URL?, Error>

  private var _originalArtwork: (String) -> AnyPublisher<URL?, Error>

  private var _description: (String) -> AnyPublisher<String?, Error>

  func sprite(for pokemon: String) -> AnyPublisher<URL?, Error> {
    self._sprite(pokemon)
  }

  func originalArtwork(for pokemon: String) -> AnyPublisher<URL?, Error> {
    self._originalArtwork(pokemon)
  }

  func description(for pokemon: String) -> AnyPublisher<String?, Error> {
    self._description(pokemon)
  }
}

// MARK: - Live Implementation
extension PokemonManager {
  static func live(session: DataTaskPublisherSession = URLSession.shared) -> Self {
    let baseUrl = "https://pokeapi.co/api/v2/"
    var pokemonCache: [String: Pokemon] = [:]

    return .init { pokemon in

      if let cached = pokemonCache[pokemon] {
        return Self.cachedPokemonRepresentation(from: cached, keypath: \.sprites.frontDefault)
      }

      return pokemonRequest(
        for: pokemon,
        baseUrl: URL(string: baseUrl)!,
        session: session,
        keypath: \.sprites.frontDefault,
        cachingFunction: { pokemonCache[pokemon] = $0 })



    } _originalArtwork: { pokemon in

      if let cached = pokemonCache[pokemon] {
        return Self.cachedPokemonRepresentation(from: cached, keypath: \.sprites.other.officialArtwork.frontDefault)
      }

      return pokemonRequest(
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
        .mapError(Self.handleNetworkError)
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
    .mapError(Self.handleNetworkError)
    .eraseToAnyPublisher()
  }

  fileprivate static func handleNetworkError(_ error: Swift.Error) -> PokemonManager.Error {
    let urlError: URLError = error as? URLError ?? URLError(.unknown, userInfo: ["error": error])
    return PokemonManager.Error.networkError(urlError)
  }

  fileprivate static func pokemonRequest(
    for pokemon: String,
    baseUrl: URL,
    session: DataTaskPublisherSession,
    keypath: KeyPath<Pokemon, URL?>,
    cachingFunction: @escaping (Pokemon) -> ()
  ) -> AnyPublisher<URL?, PokemonManager.Error> {

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
      .mapError(Self.handleNetworkError)
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
