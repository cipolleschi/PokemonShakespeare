import SwiftUI
import PokemonShakespeareKit
import PokemonShakespeareUI
import ComposableArchitecture

typealias AppStore = Store<AppState, AppAction>

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  lazy var store: AppStore =  {
    var storage = Storage.live()
    return AppStore(
      initialState: storage.get(AppReducer.stateKey)?.decoded(AppState.self) ?? .init(),
      reducer: AppReducer.combine(AppReducer.live, AppReducer.persistence),
      environment: AppEnvironment(
        pokemonManager: .live,
        mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
        storage: storage
      )
    )
  }()

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
  ) -> Bool {
    window = UIWindow(frame: UIScreen.main.bounds)
    let viewController = UIHostingController(rootView: PokemonTabbar(store: self.store))
    window?.rootViewController = viewController
    window?.makeKeyAndVisible()

    return true
  }
}
