import SwiftUI

internal class ScreenStack {
    let rootViewController: UIViewController
    
    var currentScreen: Screen
    
    init(viewController: UIViewController, screen: Screen) {
        self.rootViewController = viewController
        self.rootViewController.setScreen(screen, animated: false)
        self.currentScreen = screen
    }
    
    func push(
        screen: Screen,
        transition: TransitionStyle,
        completion: @escaping () -> Void
    ) {
        let viewController: UIViewController = screen
        switch transition {
        case .none:
            viewController.modalPresentationStyle = .fullScreen
        case .coverFullscreen:
            viewController.modalTransitionStyle = .crossDissolve
            viewController.modalPresentationStyle = .fullScreen
        case .coverOverFullscreen:
            viewController.view.backgroundColor = nil
            viewController.modalTransitionStyle = .crossDissolve
            viewController.modalPresentationStyle = .overFullScreen
        case .coverVertical:
            viewController.modalTransitionStyle = .coverVertical
            viewController.modalPresentationStyle = .fullScreen
        case .coverHorizontal:
            viewController.modalPresentationStyle = .custom
            viewController.transitioningDelegate = TransitionDelegate.coverHorizontal
        case .sheet:
            viewController.modalTransitionStyle = .coverVertical
            viewController.modalPresentationStyle = .pageSheet
        }
        
        currentScreen.present(viewController, animated: transition != .none, completion: completion)
        currentScreen = screen
    }
    
    func clear(asNewRoot screen: Screen? = nil) {
        if let screen = screen {
            rootViewController.setScreen(screen, animated: true)
            currentScreen = screen
        }
        if rootViewController.presentedViewController != nil {
            rootViewController.dismiss(animated: false)
        }
        
        print("🎱 ScreenStack/clear() 🎱")
        print("⚪️ \(self.currentScreen.name) is the new root. ⚪️")

    }
    
    func popUntil(screenName: String, inclusive: Bool, arguments: [String: Any]) {
        var screen: Screen! = currentScreen
        
        while screen != nil && screen.name != screenName {
            screen = screen.presentingViewController?.screen
        }
        if screen == nil {
            print("🎱 ScreenStack/popUntil(screenName: \(screenName), arguments: \(arguments)) 🎱")
            print("🧐 Could not retrieve any screen named \"\(screenName)\" in this hierarchy. 🧐")
            print("🚧 It should never happen : please contact developers team. 🚧")
            return
        }
        if inclusive, let parent = screen.presentingViewController?.screen {
            screen = parent
        }
        screen.dismiss(animated: true)
        currentScreen = screen
        currentScreen.onNavigateTo(arguments)
    }
    
    func pop(arguments: [String : Any]) {
        popUntil(screenName: currentScreen.name, inclusive: true, arguments: arguments)
    }
}

private extension UIViewController {
    var screen: Screen {
        self as? Screen ?? (children.first as! Screen)
    }
    
    func setScreen(_ screen: Screen, animated: Bool) {
        let oldScreen: Screen? = children.first as? Screen
        oldScreen?.view.alpha = 1.0
        
        addChild(screen)
        screen.view.frame = view.frame
        screen.view.alpha = 0.0
        view.addSubview(screen.view)
        let completion = { (finished: Bool) -> Void in
            screen.view.alpha = 1.0
            screen.didMove(toParent: self)
            if let oldScreen = oldScreen {
                oldScreen.willMove(toParent: nil)
                oldScreen.view.removeFromSuperview()
                oldScreen.removeFromParent()
            }
        }
        
        if (animated) {
            UIView.animate(withDuration: 0.25, animations: {
                screen.view.alpha = 1.0
                oldScreen?.view.alpha = 0.0
            }, completion: completion)
        } else {
            completion(true)
        }
    }
}
