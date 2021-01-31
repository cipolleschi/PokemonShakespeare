import ProjectDescription

/// Project helpers are functions that simplify the way you define your project.
/// Share code to create targets, settings, dependencies,
/// Create your own conventions, e.g: a func that makes sure all shared targets are "static frameworks"
/// See https://tuist.io/docs/usage/helpers/

extension Project {

  public struct Framework {
    let name: String
    let dependencies: [String]
    let testDependencies: [String]

    public init(name: String, dependencies: [String] = [], testDependencies: [String] = []) {
      self.name = name
      self.dependencies = dependencies
      self.testDependencies = testDependencies
    }
  }
  /// Helper function to create the Project for this ExampleApp
  public static func app(name: String, platform: Platform, additionalTargets: [Framework]) -> Project {
    var targets = makeAppTargets(
      name: name,
      platform: platform,
      dependencies:
        [TargetDependency.package(product: "ComposableArchitecture")] +
        additionalTargets.map { TargetDependency.target(name: $0.name) })
    targets += additionalTargets.flatMap({ makeFrameworkTargets(framework: $0, platform: platform) })
    return Project(
      name: name,
      organizationName: "tuist.io",
      packages: [
        .remote(
          url: "https://github.com/onevcat/Kingfisher.git",
          requirement: .upToNextMajor(from: "6.0.0")
        ),
        .remote(
          url: "https://github.com/pointfreeco/swift-snapshot-testing.git",
          requirement: .upToNextMajor(from: "1.8.1")
        ),
        .remote(
          url: "https://github.com/pointfreeco/swift-composable-architecture.git",
          requirement: .upToNextMajor(from: "0.11.0")
        )
      ],
      targets: targets
    )
  }

  // MARK: - Private

  /// Helper function to create a framework target and an associated unit test target
  private static func makeFrameworkTargets(framework: Framework, platform: Platform) -> [Target] {
    let sources = Target(name: framework.name,
                         platform: platform,
                         product: .framework,
                         bundleId: "io.tuist.\(framework.name)",
                         infoPlist: .default,
                         sources: ["Targets/\(framework.name)/Sources/**"],
                         resources: [],
                         dependencies: framework.dependencies.map { TargetDependency.package(product: $0) }
    )
    let tests = Target(name: "\(framework.name)Tests",
                       platform: platform,
                       product: .unitTests,
                       bundleId: "io.tuist.\(framework.name)Tests",
                       infoPlist: .default,
                       sources: ["Targets/\(framework.name)/Tests/**"],
                       resources: [],
                       dependencies: [.target(name: framework.name)] + framework.testDependencies.map { TargetDependency.package(product: $0) }
    )
    return [sources, tests]
  }

  /// Helper function to create the application target and the unit test target.
  private static func makeAppTargets(name: String, platform: Platform, dependencies: [TargetDependency]) -> [Target] {
    let platform: Platform = platform
    let infoPlist: [String: InfoPlist.Value] = [
      "CFBundleShortVersionString": "1.0",
      "CFBundleVersion": "1",
      "UIMainStoryboardFile": "",
      "UILaunchStoryboardName": "LaunchScreen"
    ]

    let mainTarget = Target(
      name: name,
      platform: platform,
      product: .app,
      bundleId: "io.tuist.\(name)",
      infoPlist: .extendingDefault(with: infoPlist),
      sources: ["Targets/\(name)/Sources/**"],
      resources: ["Targets/\(name)/Resources/**"],
      dependencies: dependencies
    )

    let testTarget = Target(
      name: "\(name)Tests",
      platform: platform,
      product: .unitTests,
      bundleId: "io.tuist.\(name)Tests",
      infoPlist: .default,
      sources: ["Targets/\(name)/Tests/**"],
      dependencies: [
        .target(name: "\(name)")
      ])
    return [mainTarget, testTarget]
  }
}
