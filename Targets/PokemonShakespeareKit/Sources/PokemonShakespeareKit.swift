//
//  PokemonShakespeareKit.swift
//  PokemonShakespeare
//
//  Created by Riccardo Cipolleschi on 23/01/21.
//  Copyright © 2021 tuist.io. All rights reserved.
//

import Foundation
import Combine
import UIKit
import SwiftUI

/// Main object that exposes all the API that are needed by PokemonShakespeare
/// The struct exposes both method to obtain raw data and method to obtain UIComponents
public struct PokemonShakespeareKit {
  var _description: (_ pokemon: String) -> AnyPublisher<String, KitError>
  var _availablePokemon: () throws -> AnyPublisher<[String], KitError>
  var _sprite: (_ pokemon: String) throws -> AnyPublisher<URL?, KitError>
  var _originalArtwork: (_ pokemon: String) throws -> AnyPublisher<URL?, KitError>
}

extension PokemonShakespeareKit {
  public static var live: Self {
    let pokemonManager = PokemonManager.live()
    let shakespearTranslator = ShakespeareTranslator.live()

    return self.live(pokemonManager: pokemonManager, shakespeareTranslator: shakespearTranslator)
  }

  static func live(
    pokemonManager: PokemonManager,
    shakespeareTranslator: ShakespeareTranslator
  ) -> Self {

    return .init(
      _description: { pokemon in
        do {
          return try pokemonManager
            .description(for: pokemon)
            .mapError(KitError.from(error:))
            .flatMap { description -> AnyPublisher<String, KitError> in
              do {
                return try shakespeareTranslator.translation(for: description ?? "")
                  .mapError(KitError.from(error:))
                  .eraseToAnyPublisher()
              } catch {
                if let err = error as? ShakespeareTranslator.Error {
                  return Fail<String, KitError>(error: KitError.from(error: err)).eraseToAnyPublisher()
                } else {
                  return Fail<String, KitError>(error: .invalidTranslation).eraseToAnyPublisher()
                }
              }
            }
            .eraseToAnyPublisher()

        } catch {
          if let err = error as? PokemonManager.Error {
            return Fail<String, KitError>(error: KitError.from(error: err)).eraseToAnyPublisher()
          } else if let err = error as? PokemonManager.Error {
            return Fail<String, KitError>(error: KitError.from(error: err)).eraseToAnyPublisher()
          } else {
            return Fail<String, KitError>(error: .invalidTranslation).eraseToAnyPublisher()
          }
        }
      },
      _availablePokemon: {
        return try pokemonManager
          .pokemonNames()
          .mapError(KitError.from(error:))
          .eraseToAnyPublisher()
      },
    _sprite: { pokemon in
      return try pokemonManager
        .sprite(for: pokemon)
        .mapError(KitError.from(error:))
        .eraseToAnyPublisher()
    },
    _originalArtwork: { pokemon in
      return try pokemonManager
        .originalArtwork(for: pokemon)
        .mapError(KitError.from(error:))
        .eraseToAnyPublisher()
    })
  }
}

// MARK: - Public Interface
extension PokemonShakespeareKit {
  public func description(for pokemon: String) -> AnyPublisher<String, KitError> {
    return self._description(pokemon)
  }

  public func availablePokemon() throws -> AnyPublisher<[String], KitError> {
    return try self._availablePokemon()
  }

  public func sprite(for pokemon: String) throws -> AnyPublisher<URL?, KitError> {
    return try self._sprite(pokemon)
  }

  public func originalArtwork(for pokemon: String) throws -> AnyPublisher<URL?, KitError> {
    return try self._originalArtwork(pokemon)
  }
}
