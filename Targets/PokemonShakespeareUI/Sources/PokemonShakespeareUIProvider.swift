import Foundation

public struct PokemonShakespeareUIProvider {
  var _swiftUIFullScreenComponent: (_ pokemon: PokemonVM) -> PokemonFullScreenSwiftUI
  var _swiftUICellComponent: (_ pokemon: PokemonCellVM) -> PokemonCellSwiftUI

  var _UIKitFullScreenComponent: (_ pokemon: PokemonVM) -> PokemonFullScreen
  var _UIKitCellComponent: (_ pokemon: PokemonCellVM) -> PokemonCell
}

extension PokemonShakespeareUIProvider {
  public static var live: Self {
    return .init(
      _swiftUIFullScreenComponent: { pokemon in
        return PokemonFullScreenSwiftUI(pokemonModel: pokemon)
      },
      _swiftUICellComponent: { pokemon in
        return PokemonCellSwiftUI(pokemonCellVM: pokemon)
      },
      _UIKitFullScreenComponent: { pokemon in
        let view  = PokemonFullScreen()
        view .viewModel = pokemon
        return view
      },
      _UIKitCellComponent: { pokemon in
        let view = PokemonCell()
        view .viewModel = pokemon
        return view
      }
    )
  }
}

// MARK: - Public interface
extension PokemonShakespeareUIProvider {

  public func swiftUIFullScreenComponent(for pokemon: PokemonVM) -> PokemonFullScreenSwiftUI {
    return _swiftUIFullScreenComponent(pokemon)
  }

  public func swiftUICellComponent(for pokemon: PokemonCellVM) -> PokemonCellSwiftUI {
    return _swiftUICellComponent(pokemon)
  }

  public func UIKitFullScreenComponent(for pokemon: PokemonVM) -> PokemonFullScreen {
    return _UIKitFullScreenComponent(pokemon)
  }

  public func UIKitCellComponent(for pokemon: PokemonCellVM) -> PokemonCell {
    return _UIKitCellComponent(pokemon)
  }
}
