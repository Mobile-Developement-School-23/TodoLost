import SwiftUI

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        createAndShowStartVC()
//        createAndShowStartSUIVC()
        
        return true
    }
}

// MARK: - Initial application settings

private extension AppDelegate {
    /// Создание и отображение стартового ViewController
    func createAndShowStartVC() {
        let mainVC = TaskListViewController()
        let navigationController = UINavigationController(rootViewController: mainVC)
        
        PresentationAssembly().taskList.config(
            view: mainVC,
            navigationController: navigationController
        )

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    func createAndShowStartSUIVC() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UIHostingController(rootView: TodoListSUI())
        window?.makeKeyAndVisible()
    }
}
