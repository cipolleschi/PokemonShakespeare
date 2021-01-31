import Foundation

/// Main interface to retrieve a UI specific to render some pokemon
/// The provider is able to produce both UIKit and SwiftUI representations of its components
public struct PokemonShakespeareUIProvider {
  var _swiftUIFullScreenComponent: (_ pokemon: PokemonVM) -> PokemonFullScreenSwiftUI
  var _swiftUICellComponent: (_ pokemon: PokemonCellVM) -> PokemonCellSwiftUI

  var _UIKitFullScreenComponent: (_ pokemon: PokemonVM) -> PokemonFullScreen
  var _UIKitCellComponent: (_ pokemon: PokemonCellVM) -> PokemonCell
}

extension PokemonShakespeareUIProvider {
  /// The implementation of the `PokemonShakespeareUIProvider`
  /// Use this variable to grab a reference to the UI Provider.
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
  /// Function that generates a `SwiftUI` view that renders a Pokemon full screen, starting from a VM
  /// - parameter pokemon: the view model of the pokemon that has to be rendered
  /// - returns: The `SwiftUI` view
  public func swiftUIFullScreenComponent(for pokemon: PokemonVM) -> PokemonFullScreenSwiftUI {
    return _swiftUIFullScreenComponent(pokemon)
  }

  /// Function that generates a `SwiftUI` view that renders a Pokemon in a cell, starting from a VM
  /// - parameter pokemon: the view model of the pokemon that has to be rendered
  /// - returns: The `SwiftUI` view
  public func swiftUICellComponent(for pokemon: PokemonCellVM) -> PokemonCellSwiftUI {
    return _swiftUICellComponent(pokemon)
  }

  /// Function that generates a `UIKit` view that renders a Pokemon full screen, starting from a VM
  /// - parameter pokemon: the view model of the pokemon that has to be rendered
  /// - returns: The `UIKit` view
  public func UIKitFullScreenComponent(for pokemon: PokemonVM) -> PokemonFullScreen {
    return _UIKitFullScreenComponent(pokemon)
  }

  /// Function that generates a `UIKit` view that renders a Pokemon in a cell, starting from a VM
  /// - parameter pokemon: the view model of the pokemon that has to be rendered
  /// - returns: The `UIKit` cell
  public func UIKitCellComponent(for pokemon: PokemonCellVM) -> PokemonCell {
    return _UIKitCellComponent(pokemon)
  }
}
