//
//  PokemonFullScreen.swift
//  PokemonShakespeare
//
//  Created by Riccardo Cipolleschi on 23/01/21.
//  Copyright © 2021 tuist.io. All rights reserved.
//

import UIKit
import SwiftUI
import Kingfisher

public struct PokemonFullScreenSwiftUI: UIViewRepresentable {
  public typealias UIViewType = PokemonFullScreen

  var pokemonModel: PokemonVM

  public func makeUIView(context: Context) -> PokemonFullScreen {
    let pokemonScreen = PokemonFullScreen()
    pokemonScreen.viewModel = self.pokemonModel
    return pokemonScreen
  }

  public func updateUIView(_ uiView: PokemonFullScreen, context: Context) {
    uiView.viewModel = self.pokemonModel
  }
}

public struct PokemonVM {
  let artworkURL: URL?
  let artworkLoadingImage: UIImage
  let name: String
  let description: String
}

public class PokemonFullScreen: UIView {
  var viewModel: PokemonVM? {
    didSet {
      self.update(oldModel: oldValue)
    }
  }

  private let artworkImage = UIImageView()
  private let nameLabel = UILabel()
  private let descriptionLabel = UILabel()

  public override init(frame: CGRect) {
    super.init(frame: frame)
    self.setup()
    self.style()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setup() {
    self.addSubview(self.artworkImage)
    self.addSubview(self.nameLabel)
    self.addSubview(self.descriptionLabel)
  }

  func style() {
    self.backgroundColor = .white
    self.nameLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
    self.nameLabel.textColor = .black
    self.nameLabel.textAlignment = .center

    self.descriptionLabel.font = UIFont.systemFont(ofSize: 18)
    self.descriptionLabel.textColor = .black
    self.descriptionLabel.numberOfLines = 0
  }

  func update(oldModel: PokemonVM?) {
    self.nameLabel.text = self.viewModel?.name ?? ""
    self.artworkImage.kf.setImage(
      with: self.viewModel?.artworkURL,
      placeholder: self.viewModel?.artworkLoadingImage)
    self.descriptionLabel.text = self.viewModel?.description ?? ""
  }

  public override func layoutSubviews() {
    super.layoutSubviews()

    let margin: CGFloat = 10

    self.artworkImage.frame = CGRect(
      x: margin,
      y: margin,
      width: self.bounds.width - 2 * margin,
      height: self.bounds.width - 2 * margin
    )

    self.nameLabel.frame = .zero
    self.nameLabel.sizeToFit()
    self.nameLabel.frame = CGRect(
      origin: CGPoint(
        x: (self.bounds.width - self.nameLabel.frame.size.width) / 2,
        y: self.artworkImage.frame.maxY + margin
      ),
      size: self.nameLabel.frame.size
    )

    let availableSpace = CGSize(
      width: self.bounds.width - 2 * margin,
      height: CGFloat.infinity
    )
    self.descriptionLabel.frame = .zero
    let size = self.descriptionLabel.sizeThatFits(availableSpace)
    self.descriptionLabel.frame = .init(
      origin: CGPoint(
        x: margin,
        y: self.nameLabel.frame.maxY + margin
      ),
      size: size
    )
  }
}

struct PokemonFullScreen_Previews: PreviewProvider {
    static var previews: some View {
      let model = PokemonVM(
        artworkURL: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/26.png")!,
        artworkLoadingImage: UIImage(systemName: "arrow.clockwise")!,
        name: "Raichu",
        description: "If the electrical sacks become excessively charged, RAICHU plants its tail in the ground and discharges. Scorched patches of ground will be found near this POKéMON’s nest."
      )

      return Group {
        PokemonFullScreenSwiftUI(
          pokemonModel: model
        )
        .previewDevice("iPhone 12")

        PokemonFullScreenSwiftUI(
          pokemonModel: model
        )
        .previewDevice("iPhone 8")
      }
    }
}
