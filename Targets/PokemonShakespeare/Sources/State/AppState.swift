//
//  AppState.swift
//  PokemonShakespeare
//
//  Created by Riccardo Cipolleschi on 30/01/21.
//  Copyright © 2021 tuist.io. All rights reserved.
//

import Foundation
import PokemonShakespeareUI
import PokemonShakespeareKit

struct AppState: Equatable, Codable {
  enum CodingKeys: String, CodingKey {
    case favouritePokemons
  }

  var favouritePokemons: Set<Pokemon> = []
  var pokemonFound: Pokemon? = nil
  var showPokemon: Bool = false
  var searchError: String? = nil
  var networkCallInFlight: Bool = false
}

extension AppState {
  var uiProvider: PokemonShakespeareUIProvider {
    return PokemonShakespeareUIProvider.live
  }

  var sortedFavourites: [Pokemon] {
    return self.favouritePokemons.sorted { $0.name < $1.name } 
  }
}

struct Pokemon: Equatable, Identifiable, Codable, Hashable {
  public var id: String {
    return self.name
  }

  let name: String
  let artwork: URL?
  let description: String
  let sprite: URL?
}
