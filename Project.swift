import ProjectDescription
import ProjectDescriptionHelpers

/*
                +-------------+
                |             |
                |     App     | Contains PokemonShakespeare App target and PokemonShakespeare unit-test target
                |             |
         +------+-------------+-------+
         |         depends on         |
         |                            |
 +----v-----+                   +-----v-----+
 |          |                   |           |
 |   Kit    |                   |     UI    |   Two independent frameworks to share code and start modularising your app
 |          |                   |           |
 +----------+                   +-----------+

 */

// MARK: - Project

// Creates our project using a helper function defined in ProjectDescriptionHelpers
let project = Project.app(
  name: "PokemonShakespeare",
  platform: .iOS,
  additionalTargets: [
    Project.Framework(name: "PokemonShakespeareKit"),
    Project.Framework(
      name: "PokemonShakespeareUI",
      dependencies: ["Kingfisher"],
      testDependencies: ["SnapshotTesting"]
    )
  ]
)
