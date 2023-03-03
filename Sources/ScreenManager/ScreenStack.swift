import SwiftUI

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
        arguments: [String : Any] = [:],
        transition: TransitionStyle
    ) {
        guard let newScreen = graph.buildScreen(from: screenName, and: arguments) else { return }
        append(screen: newScreen, transition: transition)
    }
    
    func append(
        screenName: String,
        transition: TransitionStyle,
        @ViewBuilder content: () -> some View
    ) {
        let newScreen = Screen(name: screenName, view: content())
        append(screen: newScreen, transition: transition)
    }
    
    private func append(
        screen: Screen,
        transition: TransitionStyle
    ) {
        if transition == .coverHorizontal {
            lastScreen.navigationController?.pushViewController(screen, animated: true)
        } else {
            if transition == .dialog { screen.view.backgroundColor = nil }
            
            let navigationController = NavigationController(viewController: screen)
            navigationController.setOnViewBeingDismissed { self.stack.removeAfter(screen, inclusive: true) }
            navigationController.modalTransitionStyle   = transition == .coverVertical || transition == .sheet ? .coverVertical : .crossDissolve
            navigationController.modalPresentationStyle = transition == .dialog         ? .overFullScreen :
                                                          transition == .coverVertical  ? .fullScreen :
                                                          transition == .sheet          ? .pageSheet
                                                        /*transition == .crossDissolve*/: .overCurrentContext
            lastScreen.present(navigationController, animated: true)
        }
        self.stack.append(screen)
    }
    
    func clear() {//TODO: Fix behavior in 1.2.1
        self.stack = [lastScreen]
        if let parentNavigationController = lastScreen.navigationController {
            parentNavigationController.setViewControllers(stack, animated: true)
        }
        print("🎱 ScreenStack/clear() 🎱")
        print("⚪️ \(lastScreen.name) is the new root. ⚪️")
    }
    
    func removeUntil(screenName: String, inclusive: Bool, arguments: [String : Any]) {
        guard let screenToReachIndex = stack.firstIndex(where: { $0.name == screenName }) else {
            print("🎱 ScreenStack/removeUntil(screenName:\(screenName), arguments:\(arguments)) 🎱")
            print("🧐 Could not retrieve any screen named \"\(screenName)\" in this hierarchy. 🧐")
            print("🚧 It should never happen : please contact developers team. 🚧")
            return
        }
        var count = endIndex - screenToReachIndex
        if screenToReachIndex > 0 && inclusive {
            count += 1
        }
        removeLast(k: count, arguments: arguments)
    }
    
    func removeLast(
        k: Int = 1,
        arguments: [String : Any]
    ) {
        guard self.stack.count > k else { /// The number of screen stacked must be higher than the number we are willing to remove.
            print("🎱 ScreenStack/removeLast(k:\(k), arguments:\(arguments)) 🎱")
            print("🧐 The amount of screen you want to remove exceed the actual content count. 🧐")
            print("🚧 It should never happen : please contact developers team. 🚧")
            return
        }
        
        ///In order to reduce the number of call to ``UIViewController/dismiss(animated, completion)`` :
        /// - We extract the screens that we want to remove.
        /// - We distinct screens by their `modalPresentationStyle`
        /// - We reverse the collection in order to dismiss the topest screen first.
        for screen in stack.removeLast(k: k)
            .distinct(by: \.navigationController?.modalPresentationStyle)
            .reversed() { screen.presentingViewController?.dismiss(animated: true) }
        
        let lastNavigationController = lastScreen.navigationController as? NavigationController
        lastNavigationController?.safePopTo(viewController: lastScreen)
        lastScreen.onNavigateTo(arguments)
    }
}
