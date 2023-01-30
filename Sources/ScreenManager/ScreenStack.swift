import UIKit

internal class ScreenStack: NavigationController {
    private let graph: NavGraph
    private(set) var stack: [Screen]
    private var endIndex: Int { stack.endIndex - 1 }
    var lastScreen: Screen { stack[endIndex] }
    
    init(graph: NavGraph, firstScreenName: String, arguments: [String:Any] = [:]) {
        self.graph = graph
        let firstScreen = graph.buildScreen(from: firstScreenName, and: arguments)!
        self.stack = [firstScreen]
        super.init(viewController: firstScreen)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func append(
        screenName: String,
        arguments: [String: Any] = [:],
        transition: TransitionStyle
    ) {
        guard let newScreen = graph.buildScreen(from: screenName, and: arguments) else { return }
        
        if transition == .coverHorizontal {
            lastScreen.navigationController?.pushViewController(newScreen, animated: true)
        } else {
            let navigationController = NavigationController(viewController: newScreen)
            navigationController.modalPresentationStyle = .fullScreen
            navigationController.modalTransitionStyle = transition == .crossDissolve ? .crossDissolve : .coverVertical
            lastScreen.navigationController?.present(navigationController, animated: true)
        }
        self.stack.append(newScreen)
    }
    
    func clear() {
        self.stack = [lastScreen]
        if let parentNavigationController = lastScreen.navigationController {
            parentNavigationController.setViewControllers(stack, animated: true)
        }
        print("ScreenStack/clear() • \(lastScreen.name) is the new root.")
    }
    
    func removeUntil(screenName: String, arguments: [String: Any]) {
        guard let screenToReachIndex = stack.firstIndex(where: { $0.name == screenName }) else {
            print("ScreenStack/removeUntil(screenName:\(screenName), arguments:\(arguments)) • Could not retreive any screen named \"\(screenName)\" in this hierarchy.")
            print("Actual stack is : [\(stack.listString { $0.name })]")
            return
        }
        let count = endIndex - screenToReachIndex
        removeLast(k: count, arguments: arguments)
    }
    
    func removeLast(
        k: Int = 1,
        arguments: [String: Any]
    ) {
        guard self.stack.count > k else { /// The number of screen stacked must be higher than the number we are willing to remove.
            print("ScreenStack/removeLast(k:\(k), arguments:\(arguments)) • The amount of screen you want to remove exceed the actual content count.")
            return
        }
        let removedScreenNavigationController = lastScreen.navigationController
        stack.removeLast(k)
        lastScreen.onNavigateTo(arguments)
        let lastNavigationController = lastScreen.navigationController as? NavigationController
        if removedScreenNavigationController == lastNavigationController {
            lastNavigationController?.safePopTo(viewController: lastScreen)
        } else {
            lastNavigationController?.dismiss(animated: true)
        }
    }
}
