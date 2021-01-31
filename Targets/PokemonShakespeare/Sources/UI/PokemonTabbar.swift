//
//  Tabbar.swift
//  PokemonShakespeare
//
//  Created by Riccardo Cipolleschi on 30/01/21.
//  Copyright © 2021 tuist.io. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

struct PokemonTabbar: View {
  let store: Store<AppState, AppAction>

  var body: some View {
    WithViewStore(self.store) { viewStore in
      TabView {
        Search(store: self.store)
          .tabItem {
            Image(systemName: "magnifyingglass.circle")
            Text("Search")
          }
        Favourites(store: self.store)
          .tabItem {
            Image(systemName: "star")
            Text("Favourites")
          }
      }
      .font(.headline)
      .sheet(
          isPresented: viewStore.binding(
            get: { $0.showPokemon },
            send: AppAction.dismissPokemon
          )
        ) {
          PokemonView(store: self.store)
        }
      .alert(
        item: viewStore.binding(
          get: { $0.searchError.map {
            AlertModel(message: $0)
          }},
          send: AppAction.cleanupError
        ),
        content: { model in
          return Alert(
            title: Text("Error"),
            message: Text(model.message))
        })
    }
  }
}

struct AlertModel: Identifiable {
  let message: String
  var id: String {
    return message
  }
}
