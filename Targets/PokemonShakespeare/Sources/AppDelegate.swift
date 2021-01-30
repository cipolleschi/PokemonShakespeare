import UIKit
import PokemonShakespeareKit
import PokemonShakespeareUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let viewController = ViewController()
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()

        return true
    }

}

class ViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    let view = self.view
    view?.backgroundColor = .red

    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {

    }

  }
}

class NC: UINavigationController {
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationBar.topItem?.title = "Secret Menu"
  }
}
