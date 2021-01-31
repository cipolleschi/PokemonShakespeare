//
//  Favourites.swift
//  PokemonShakespeare
//
//  Created by Riccardo Cipolleschi on 31/01/21.
//  Copyright © 2021 tuist.io. All rights reserved.
//

import SwiftUI
import ComposableArchitecture
import PokemonShakespeareUI

struct Favourites: View {
  var store: AppStore

  var body: some View {
    WithViewStore(self.store) { viewStore in
      NavigationView {
        ZStack {
          Text("No favourites yet")
            .font(.headline)
            .hidden(shouldHide: !viewStore.favouritePokemons.isEmpty)

          List {
            ForEach(viewStore.sortedFavourites) { pokemon in
              NavigationLink(
                destination: viewStore.uiProvider.swiftUIFullScreenComponent(for: pokemon.vm)
              ) {
                viewStore.uiProvider.swiftUICellComponent(for: pokemon.cellVM)
              }
            }.onDelete(perform: { indexSet in
              let pokemon = viewStore.sortedFavourites[indexSet.first!]
              viewStore.send(AppAction.changeFavourite(pokemon))
            })
          }.hidden(shouldHide: viewStore.favouritePokemons.isEmpty)

          
        }.navigationBarTitle("Favourites", displayMode: .automatic)
      }
    }
  }
}

extension Pokemon {
  var cellVM: PokemonCellVM {
    return PokemonCellVM(
      name: self.name,
      spriteURL: self.sprite,
      spriteLoadingImage: PokemonShakespeareAsset.pokeball.image)
  }
}

struct Favourites_Previews: PreviewProvider {
  static var previews: some View {
    let appStore = AppStore(
      initialState: .init(favouritePokemons: [
        Pokemon(
          name: "Pikachu",
          artwork: nil,
          description: "This is a description",
          sprite: nil
        ),
        Pokemon(
          name: "Charmender",
          artwork: nil,
          description: "This is a description",
          sprite: nil
        ),
        Pokemon(
          name: "Bulbasaur",
          artwork: nil,
          description: "This is a description",
          sprite: nil
        )
      ] ),
      reducer: AppReducer.live,
      environment: AppEnvironment.init(
        pokemonManager: .live,
        mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
        storage: .live()
      )
    )
    Favourites(store: appStore)
  }
}
