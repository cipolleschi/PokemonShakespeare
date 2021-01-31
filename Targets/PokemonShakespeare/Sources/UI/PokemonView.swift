//
//  PokemonView.swift
//  PokemonShakespeare
//
//  Created by Riccardo Cipolleschi on 30/01/21.
//  Copyright © 2021 tuist.io. All rights reserved.
//

import SwiftUI
import ComposableArchitecture
import PokemonShakespeareUI


struct PokemonView: View {
  let store: AppStore

  var body: some View {
    WithViewStore(self.store) { viewStore in

      ZStack {

        viewStore.uiProvider.swiftUIFullScreenComponent(
          for: viewStore.pokemonFound!.vm
        )
        .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
        VStack {
          HStack {
            Button {
              viewStore.send(AppAction.dismissPokemon)
            } label: {
              Image(systemName: "xmark")
                .accentColor(.black)
                .padding()
            }

            let isFavorite = viewStore.favouritePokemons.contains(viewStore.pokemonFound!)
            Spacer()

            Text("\(isFavorite ? "Remove from" : "Add to")  Favourites")
            Button {
              viewStore.send(AppAction.changeFavourite(viewStore.pokemonFound!))
            } label: {
              Image(systemName: isFavorite ? "star.fill" : "star")
            }

          }.padding(
            EdgeInsets(
              top: 0,
              leading: 0,
              bottom: 0,
              trailing: 20
            )
          )

          Spacer()
        }

      }

    }
  }
}



struct PokemonView_Previews: PreviewProvider {
  static var previews: some View {
    let pokemon = Pokemon(
      name:"Pikachu",
      artwork: nil,
      description: "Something",
      sprite: nil
    )
    return PokemonView(
      store: .init(
        initialState: .init(
          favouritePokemons: [pokemon],
          pokemonFound: pokemon
        ),
        reducer: .live,
        environment: AppEnvironment.init(
          pokemonManager: .live,
          mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
          storage: .live()
        )
      )
    )
  }
}
