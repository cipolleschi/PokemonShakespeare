//
//  PokemonCell.swift
//  PokemonShakespeare
//
//  Created by Riccardo Cipolleschi on 23/01/21.
//  Copyright © 2021 tuist.io. All rights reserved.
//

import UIKit
import SwiftUI
import Kingfisher

public struct PokemonCellSwiftUI: UIViewRepresentable {
  public typealias UIViewType = PokemonCell

  var pokemonCellVM: PokemonCellVM

  public func makeUIView(context: Context) -> PokemonCell {

    let cell = PokemonCell()
    cell.viewModel = self.pokemonCellVM
    return cell
  }

  public func updateUIView(_ uiView: PokemonCell, context: Context) {
    uiView.viewModel = pokemonCellVM
  }
}

public struct PokemonCellVM {
  let name: String
  let spriteURL: URL?
  let spriteLoadingImage: UIImage
}

public class PokemonCell: UITableViewCell {
  static let reuseIdentifier: String = "\(PokemonCell.self)"

  var viewModel: PokemonCellVM? {
    didSet {
      self.update(oldModel: oldValue)
    }
  }

  private let nameLabel = UILabel()
  private let spriteImage = UIImageView()

  public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.setup()
    self.style()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setup() {
    self.addSubview(self.nameLabel)
    self.addSubview(self.spriteImage)
  }

  func style() {
    self.backgroundColor = .white
    self.nameLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
    self.nameLabel.textColor = .black
  }

  func update(oldModel: PokemonCellVM?) {
    self.nameLabel.text = self.viewModel?.name ?? ""
    self.spriteImage.kf.setImage(
      with: self.viewModel?.spriteURL,
      placeholder: self.viewModel?.spriteLoadingImage)
  }

  public override func layoutSubviews() {
    super.layoutSubviews()

    let margin: CGFloat = 10

    self.spriteImage.frame = CGRect(
      x: margin,
      y: -margin / 2 ,
      width: self.bounds.height + margin,
      height: self.bounds.height + margin
    )

    self.nameLabel.frame = .zero
    self.nameLabel.sizeToFit()
    self.nameLabel.frame = CGRect(
      origin: CGPoint(
        x: self.spriteImage.frame.maxX + margin,
        y: (self.bounds.height - self.nameLabel.frame.height) / 2
      ),
      size: self.nameLabel.frame.size
    )
  }
}

struct PokemonCell_Previews: PreviewProvider {
    static var previews: some View {
      List {
        PokemonCellSwiftUI(
          pokemonCellVM: .init(
            name: "Charmander",
            spriteURL: URL(
              string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/26.png")!,
            spriteLoadingImage: UIImage(systemName: "arrow.clockwise")!
          )
        )
      }.environment(\.defaultMinListRowHeight, 60)
    }
}
