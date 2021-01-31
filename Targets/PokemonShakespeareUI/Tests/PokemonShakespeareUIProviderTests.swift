import Foundation
import XCTest
import SnapshotTesting
import PokemonShakespeareUI

final class PokemonShakespeareUIProviderTests: XCTestCase {


  func test_fullScreen_UIKit() {
    let provider = PokemonShakespeareUIProvider.live
    let view = provider.UIKitFullScreenComponent(for: Self.pokemonVM)
      
    assertSnapshot(matching: view, as: Snapshotting.image)
  }

  func test_cell_UIKit() {
    let provider = PokemonShakespeareUIProvider.live
    let view = provider.UIKitCellComponent(for: Self.pokemonCellVM)

    assertSnapshot(matching: view, as: Snapshotting.image)
  }

  func test_fullScreen_SwiftUI() {
    let provider = PokemonShakespeareUIProvider.live
    let view = provider.swiftUIFullScreenComponent(for: Self.pokemonVM)

    assertSnapshot(matching: view, as: Snapshotting.image)
  }

  func test_cell_SwiftUI() {
    let provider = PokemonShakespeareUIProvider.live
    let view = provider.swiftUICellComponent(for: Self.pokemonCellVM)

    assertSnapshot(matching: view, as: Snapshotting.image)
  }
}

extension PokemonShakespeareUIProviderTests {
  static let pokemonVM = PokemonVM(
      artworkURL: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/26.png")!,
      artworkLoadingImage: UIImage(systemName: "arrow.clockwise")!,
      name: "Raichu",
      description: "If the electrical sacks become excessively charged, RAICHU plants its tail in the ground and discharges. Scorched patches of ground will be found near this POKéMON’s nest."
    )

  static let pokemonCellVM = PokemonCellVM(
    name: "Charmander",
    spriteURL: URL(
      string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/26.png")!,
    spriteLoadingImage: UIImage(systemName: "arrow.clockwise")!
  )
}
