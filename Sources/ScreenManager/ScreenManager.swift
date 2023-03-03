import SwiftUI

internal class ScreenManager {
    private let graph: NavGraph
    private let root: String
    private var screenStack: ScreenStack! = nil
    
    var uiViewController: UIViewController {
        if screenStack == nil {
            ///This `ScreenStack` is initialized at the request of the `NavHost` to avoid UI blocking that can occur when interacting with the root screen.
            self.screenStack = ScreenStack(graph: self.graph, firstScreenName: self.root)
        }
        return screenStack
    }
    
    init(graph: NavGraph, root: String) {
        self.graph = graph
        self.root = root
    }
    
    func clearBackstack() {
        screenStack.clear()
    }
    
    func pop(to screenName: String?, inclusive: Bool, arguments: [String : Any]) {
        if let screenName = screenName {
            popTo(screenName: screenName, inclusive: inclusive, arguments: arguments)
        } else {
            popLast(inclusive: inclusive, arguments: arguments)
        }
    }
    
    private func popTo(screenName: String, inclusive: Bool, arguments: [String : Any]) {
        guard screenStack.stack.contains(where: {$0.name == screenName}) else {
            print("🎱 ScreenManager/popTo(screenName:\(screenName), inclusive: \(inclusive), arguments:\(arguments)) 🎱")
            print("🧐 Could not retrieve any screen named \"\(screenName)\" in this hierarchy. 🧐")
            print("👉 Current stack is : \(screenStack.stack.map { $0.name }) 👈")
            return
        }
        screenStack.removeUntil(screenName: screenName, inclusive: inclusive, arguments: arguments)
    }
    
    private func popLast(inclusive: Bool, arguments: [String : Any]) {
        let screensToRemove = inclusive ? 2 : 1
        if screenStack.stack.count > screensToRemove {
            screenStack.removeLast(k: screensToRemove, arguments: arguments)
        } else {
            print("🎱 ScreenManager/popLast(inclusive: \(inclusive), arguments:\(arguments)) 🎱")
            print("🧐 There is not enough screens to remove in this hierarchy. 🧐")
            print("👉 Current stack is : \(screenStack.stack.map { $0.name }) 👈")
        }
    }
    
    func push(
        screenName: String,
        arguments: [String : Any],
        transition: TransitionStyle,
        asNewRoot: Bool = false
    ) {
        screenStack.append(screenName: screenName, arguments: arguments, transition: transition)
        if asNewRoot { clearBackstack() }
    }
    
    func push(
        screenName: String,
        transition: TransitionStyle,
        asNewRoot: Bool = false,
        @ViewBuilder content: () -> some View
    ) {
        screenStack.append(screenName: screenName, transition: transition, content: content)
        if asNewRoot { clearBackstack() }
    }
    
    func setOnNavigateBack(block: @escaping ([String : Any]) -> Void) {
        screenStack.lastScreen.onNavigateTo = { block($0) }
    }
}
