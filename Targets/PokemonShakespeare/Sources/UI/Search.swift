//
//  Search.swift
//  PokemonShakespeare
//
//  Created by Riccardo Cipolleschi on 30/01/21.
//  Copyright © 2021 tuist.io. All rights reserved.
//

import SwiftUI
import ComposableArchitecture
import PokemonShakespeareUI

struct Search: View {
  @State var userInput: String = ""
  let store: AppStore

  var body: some View {
    WithViewStore(self.store) { viewStore in
      ZStack {
        Rectangle().fill(Color.white)
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
          .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
          }
        HStack {
          TextField(
            "Search...",
            text: $userInput
          )
          .disableAutocorrection(true)
          .autocapitalization(.none)
          Button {
            viewStore.send(.searchPokemon(userInput))
          } label: {
            Image(systemName: "magnifyingglass")
              .padding(10)
              .accentColor(.white)
              .background(RoundedRectangle(cornerRadius: 5).fill(Color.blue))
              .cornerRadius(5)
          }
        }
        .padding(20)

        Loader().hidden(shouldHide: !viewStore.networkCallInFlight)

      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
  }
}

extension Pokemon {
  var vm: PokemonVM {
    return PokemonVM(
      artworkURL: self.artwork,
      artworkLoadingImage: PokemonShakespeareAsset.pokeball.image,
      name: self.name,
      description: self.description
    )
  }
}

struct Search_Previews: PreviewProvider {
  static var previews: some View {
    let appStore = AppStore(
      initialState: .init(),
      reducer: .live,
      environment: AppEnvironment(
        pokemonManager: .live,
        mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
        storage: .live()
      )
    )
    Search(store: appStore)
  }
}
