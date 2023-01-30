import UIKit

internal class ScreenManager {
    private let graph: NavGraph
    private let root: String
    private var mainScreenStack: ScreenStack! = nil
    private var modalScreenStack: ScreenStack? = nil
    
    var uiViewController: UIViewController {
        if mainScreenStack == nil {
            ///This `ScreenStack` is initialized at the request of the `NavHost` to avoid UI blocking that can occur when interacting with the root screen.
            self.mainScreenStack = ScreenStack(graph: self.graph, firstScreenName: self.root)
        }
        return mainScreenStack
    }
    
    init(graph: NavGraph, root: String) {
        self.graph = graph
        self.root = root
    }
    
    func clearBackstack(fromContext: Bool = true) {
        if let modalScreenStack = modalScreenStack, fromContext {
            modalScreenStack.clear()
        } else {
            modalScreenStack = nil
            mainScreenStack.clear()
        }
    }
    
    func pop(to screenName: String?, arguments: [String: Any]) {
        if let screenName = screenName {
            popTo(screenName: screenName, arguments: arguments)
        } else {
            popLast(arguments: arguments)
        }
    }
    
    private func popTo(screenName: String, arguments: [String: Any]) {
        let modalContainsScreen = modalScreenStack?.stack.contains(where: {$0.name == screenName})
        if modalContainsScreen == true { /// Modal context
            modalScreenStack?.removeUntil(screenName: screenName, arguments: arguments)
        } else { /// Main context.
            dismissModal(arguments: arguments)
            mainScreenStack.removeUntil(screenName: screenName, arguments: arguments)
        }
    }
    
    private func popLast(arguments: [String: Any]) {
        if let modalScreenStack = modalScreenStack { /// Modal context
            if modalScreenStack.stack.count > 1 {
                modalScreenStack.removeLast(arguments: arguments)
            } else {
                dismissModal(arguments: arguments)
            }
        } else { /// Main context
            mainScreenStack.removeLast(arguments: arguments)
        }
    }
    
    func push(
        screenName: String,
        arguments: [String: Any],
        transition: TransitionStyle,
        asNewRoot: Bool = false
    ) {
        let screenStack = modalScreenStack ?? mainScreenStack
        screenStack?.append(screenName: screenName, arguments: arguments, transition: transition)
        if asNewRoot { clearBackstack() }
    }
    
    func showModal(
        screenName: String,
        arguments: [String: Any]
    ) {
        if modalScreenStack == nil {
            modalScreenStack = ScreenStack(graph: graph, firstScreenName: screenName, arguments: arguments)
            mainScreenStack.present(modalScreenStack!, animated: true)
            modalScreenStack!.setOnViewBeingDismissed { [unowned self] in self.modalScreenStack = nil }
        } else {
            print("ScreenManager/showModal(screenName:\(screenName), arguments:\(arguments)) • Could not show modal as one is already displayed.")
        }
    }
    
    func dismissModal(arguments: [String: Any]) {
        modalScreenStack = nil
        mainScreenStack.dismiss(animated: true)
        mainScreenStack.lastScreen.onNavigateTo(arguments)
    }
    
    func setOnNavigateBack(block: @escaping ([String: Any]) -> Void) {
        let screenStack = modalScreenStack ?? mainScreenStack
        screenStack?.lastScreen.onNavigateTo = { block($0) }
    }
}
