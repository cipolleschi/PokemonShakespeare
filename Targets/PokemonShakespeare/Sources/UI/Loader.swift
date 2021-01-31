//
//  Loader.swift
//  PokemonShakespeare
//
//  Created by Riccardo Cipolleschi on 30/01/21.
//  Copyright © 2021 tuist.io. All rights reserved.
//

import SwiftUI

struct Loader: View {
    var body: some View {
      VStack {
        Text("Searching...").font(.title)
        ProgressView()
          .foregroundColor(.white)
          .accentColor(Color.white)
      }
      .frame(width: 350, height: 200, alignment: .center)
      .background(RoundedRectangle(cornerRadius: 20).fill(Color.gray.opacity(0.5)))
    }
}

struct Loader_Previews: PreviewProvider {
    static var previews: some View {
        Loader()
    }
}

extension View {
  @ViewBuilder func hidden(shouldHide: Bool) -> some View {
    switch shouldHide {
    case true: self.hidden()
    case false: self
    }
  }
}
