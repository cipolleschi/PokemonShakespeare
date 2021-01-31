//
//  PokemonShakespeareKit.swift
//  PokemonShakespeare
//
//  Created by Riccardo Cipolleschi on 23/01/21.
//  Copyright © 2021 tuist.io. All rights reserved.
//

import Foundation
import Combine

/// Main object that exposes all the API that are needed by PokemonShakespeare
/// The struct exposes both method to obtain raw data and method to obtain UIComponents
public struct PokemonShakespeareKit {
  private var _description: (_ pokemon: String) -> AnyPublisher<String, KitError>
  private var _sprite: (_ pokemon: String) -> AnyPublisher<URL?, KitError>
  private var _originalArtwork: (_ pokemon: String) -> AnyPublisher<URL?, KitError>
}

extension PokemonShakespeareKit {

  /// Default implementation of the `PokemonShakespeareKit` SDK.
  /// Use this property to obtain a reference to the Service that is correctly initialized
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
        return pokemonManager
          .description(for: pokemon)
          .mapError(KitError.from(error:))
          .flatMap { description -> AnyPublisher<String, KitError> in
            return shakespeareTranslator.translation(for: description ?? "")
              .mapError(KitError.from(error:))
              .eraseToAnyPublisher()
          }
          .eraseToAnyPublisher()
      },
      _sprite: { pokemon in
        return pokemonManager
          .sprite(for: pokemon)
          .mapError(KitError.from(error:))
          .eraseToAnyPublisher()
      },
      _originalArtwork: { pokemon in
        return pokemonManager
          .originalArtwork(for: pokemon)
          .mapError(KitError.from(error:))
          .eraseToAnyPublisher()
      })
  }
}

// MARK: - Public Interface
extension PokemonShakespeareKit {

  /// Function that returns a publisher to obtain the description of a pokemon, already translated in Shapespeare language.
  ///
  /// - parameter pokemon: the name of the pokemon
  /// - returns: a `Publisher<String, KitError>` that produces the description of the pokemon
  public func description(for pokemon: String) -> AnyPublisher<String, KitError> {
    return self._description(pokemon)
  }

  /// Function that returns a sprite of a pokemon, given its name
  ///
  /// - parameter pokemon: the name of the pokemon
  /// - returns: a `Publisher<URL, KitError>` that produces the url for pokemon's sprite
  public func sprite(for pokemon: String) -> AnyPublisher<URL?, KitError> {
    return self._sprite(pokemon)
  }

  /// Function that returns the artwork of a pokemon, given its name
  ///
  /// - parameter pokemon: the name of the pokemon
  /// - returns: a `Publisher<URL, KitError>` that produces the url for pokemon's artwork
  public func originalArtwork(for pokemon: String) -> AnyPublisher<URL?, KitError> {
    return self._originalArtwork(pokemon)
  }
}
