import SwiftUI

/// NavController is the part of the Navigation that orchestrate how screens are displayed.
///
/// The ``NavController`` is declared once and passed through the ``NavHost``
/// ```
///@main
///struct SampleApp: App {
///    @ObservedObject var controller =
///        NavController(
///            root: Route.Splash.name
///        ) { graph in
///            graph.screen("Splash") { SplashScreen() }
///            graph.screen("Home") { HomeScreen() }
///            graph.screen("FirstName") { FirstNameScreen() }
///            graph.screen("LastName") { navParams in
///                let firstName = navParams["first_name"] as! String
///                LastNameScreen(firstName: firstName)
///            }
///        }
///
///    init() {
///        register(
///            assemblies: [ AppAssembly(navController: self.controller) ]
///        )
///    }
///
///    var body: some Scene {
///        WindowGroup {
///            NavHost(controller: controller)
///                .background(.clear)
///                .preferredColorScheme(.dark)
///                .clipped()
///        }
///    }
///}
/// ```
/// After having set a `root` screen name to define which screen will
/// be displayed first and the graph of the app navigation :
/// ```
///    @ObservedObject var controller =
///        NavController(
///            root: Route.Splash.name
///        ) { graph in
///            graph.screen("Splash") { SplashScreen() }
///            graph.screen("Home") { HomeScreen() }
///            graph.screen("FirstName") { FirstNameScreen() }
///            graph.screen("LastName") { navParams in
///                let firstName = navParams["first_name"] as! String
///                LastNameScreen(firstName: firstName)
///            }
///        }
/// ```
/// The navController is ready to manage the screens once it is passed as
/// parameter through the ``NavHost`` :
///
/// ```
///        NavHost(controller: controller)
/// ```
///
/// > Warning ;
/// > To use the ``NavController`` properly you have to use the same
/// > instance of the class that you have initialized with the graph, consider
/// > using singleton pattern or external ioc library as ``Swinject``.
///
/// After that, inject the navController anywhere you want to use it.
/// ```
///private class HomeViewModel: ObservableObject {
///    private var controller: NavController = resolve()
///
///    func goToFirstName() {
///        controller.showModal(
///            screenName: Route.FirstName.name
///        )
///    }
///
///    func clearBackstack() {
///        controller.clearBackstack()
///    }
///
///    func backToSplash() {
///        controller.pop()
///    }
///}
/// ```
public class NavController: ObservableObject {
    internal let screenManager: ScreenManager
    
    /// - Parameters:
    ///     - root: The name of the first screen that will be displayed.
    ///     - builder: ``NavGraphBuilder`` that defines how the app screens will be built.
    public init(
        root: String,
        builder: NavGraphBuilder
    ) {
        let graph = NavGraph()
        builder(graph)
        self.screenManager = ScreenManager(graph: graph, root: root) 
    }
    
    /// Clear the entire backstack under the last view and set it as new `root`.
    ///
    /// Use this method to keep only the last screen displayed into its stack.
    /// ```
    /// // mainStack : ScreenA, ScreenB, ScreenC and ScreenD.
    ///
    /// controller.clearBackstack()
    ///
    /// // mainStack : ScreenD
    /// ```
    /// When a modal is presented and ``NavController/clearBackstack(fromContext:)`` with a `false` parameter is called, the modal
    /// dismiss, each screen related to the modal are removed from the backstack
    /// and the last screen of the `mainStack` becomes the top view displayed.
    /// ```
    /// // mainStack : ScreenA and ScreenB.
    /// // modalStack : ModalA and ModalB.
    ///
    /// controller.clearBackstack(fromContext: false)
    ///
    /// // mainStack : ScreenB
    /// // modalStack : nil
    /// ```
    ///
    /// - Parameters:
    ///     - fromContext: If this ``Bool`` is true, the clear will occur into the current navigation context : whether or not the app is presenting a modal. If it is false only the last screen of the main navigation will remain.
    public func clearBackstack(fromContext: Bool = true) {
        screenManager.clearBackstack(fromContext: fromContext)
    }
    
    /// Display a screen that was shown previously into the hierarchy.
    ///
    /// Use this method to remove one or many screens from the backstack.
    /// ```
    /// // mainStack : ScreenA, ScreenB, ScreenC and ScreenD.
    ///
    /// controller.pop()
    ///
    /// // new content : ScreenA, ScreenB and ScreenC
    /// ```
    /// When a modal is presented and ``NavController/pop(to:arguments:)`` is called the modal may dismiss if all parameters are met.
    /// ```
    /// // mainStack : ScreenA, ScreenB, ScreenC and ScreenD.
    /// // modalStack : ModalA, ModalB and ModalC
    ///
    /// controller.pop(to: "ScreenB")
    ///
    /// // mainStack : ScreenA and ScreenB
    /// // modalStack : nil
    /// ```
    /// As you can see in the above example, as we are using `ScreenB` screenName in parameter : we are popping to its related screen
    /// and each screen shown after `ScreenB` are erased from backstack.
    ///
    /// - Parameters:
    ///     - screenName: This `String?` allows you to navigate back to a chosen screen by entering its name.
    ///     - arguments: This `Dictionary` holds, under its key/value pairs, data that you want to share with the popped screen.
    public func pop(to screenName: String? = nil, arguments: [String: Any] = [:]) {
        screenManager.pop(to: screenName, arguments: arguments)
    }
    
    /// Push a new screen to the backstack.
    ///
    /// Use this method to add a screen to the last navigation contexts stack.
    /// ```
    /// // mainStack : ScreenA, ScreenB and ScreenC.
    /// // modalStack : ModalA and ModalB.
    ///
    /// controller.push(screenName: "ModalC")
    ///
    /// // mainStack : ScreenA, ScreenB and ScreenC.
    /// // modalStack : ModalA, ModalB and ModalC.
    /// ```
    /// Depending the parameters used, the screen could be the only one in the stack.
    /// ```
    /// // mainStack : ScreenA, ScreenB and ScreenC.
    ///
    /// controller.push(screenName: "ScreenD", asNewRoot: true)
    ///
    /// // mainStack : ScreenD
    /// ```
    /// If the controller cannot find any related view from the graph, console will prompt logs.
    /// 
    /// - Parameters:
    ///     - screenName: The name of the screen that will be used to retrieve a ViewBuilding from the `NavGraph`.
    ///     - arguments: This `Dictionary` holds, under its key/value pairs, data that you want to share with the newly pushed screen.
    ///     - transition: Sets the animation that will be triggered.
    ///     - asNewRoot: Indicate wheter or not the pushed destination will become root.
    public func push(
        screenName: String,
        arguments: [String: Any] = [:],
        transition: TransitionStyle = .coverHorizontal,
        asNewRoot: Bool = false
    ) {
        screenManager.push(screenName: screenName, arguments: arguments, transition: transition, asNewRoot: asNewRoot)
    }
    
    /// Presents a screen into a modal presentation style.
    ///
    /// Use this method to show the modal navigation context.
    /// ```
    /// // mainStack : ScreenA, ScreenB and ScreenC.
    /// // modalStack : nil
    ///
    /// controller.showModal(screenName: "ModalA")
    ///
    /// // mainStack : ScreenA, ScreenB and ScreenC.
    /// // modalStack : ModalA.
    /// ```
    /// If the controller cannot find any related view from the graph, console will prompt logs.
    /// If the modal navigation context is already displayed, nothing else will happen.
    ///
    /// - Parameters:
    ///     - screenName: The name of the screen that will be used to retrieve a ViewBuilding from the `NavGraph`.
    ///     - arguments: This `Dictionary` holds, under its key/value pairs, data that you want to share with the modal.
    public func showModal(
        screenName: String,
        arguments: [String: Any] = [:]
    ) {
        screenManager.showModal(screenName: screenName, arguments: arguments)
    }
    
    /// Dismiss the displayed modal.
    ///
    /// When a modal is presented and ``NavController/dismissModal(arguments:)`` is called, the modal
    /// dismiss and each screen related to the modal are removed from backstack.
    /// ```
    /// // mainStack : ScreenA and ScreenB.
    /// // modalStack : ModalA and ModalB.
    ///
    /// controller.dismissModal()
    ///
    /// // mainStack : ScreenA and ScreenB.
    /// // modalStack : nil
    /// ```
    ///
    /// - Parameters:
    ///     - arguments: This `Dictionary` holds, under its key/value pairs, data that you want to share with the popped screen.
    public func dismissModal(arguments: [String: Any] = [:]) {
        screenManager.dismissModal(arguments: arguments)
    }
    
    
    /// Dismiss the displayed modal.
    ///
    /// When a modal is presented and ``NavController/dismissModal(arguments:)`` is called, the modal
    /// dismiss and each screen related to the modal are removed from backstack.
    /// ```
    ///    private init() {
    ///        controller.setOnNavigateBack { args in
    ///            if let firstName = args["first_name"] as? String, !firstName.isEmpty {
    ///                self.firstName = firstName
    ///            }
    ///
    ///            if let lastName = args["last_name"] as? String, !lastName.isEmpty {
    ///                self.lastName = lastName
    ///            }
    ///        }
    ///    }
    /// ```
    ///
    /// - Parameters:
    ///     - block: This lambda defines how the screen will be generated, the dictionary passed as entry parameter works as an arguments map.
    public func setOnNavigateBack(block: @escaping ([String: Any]) -> Void) {
        screenManager.setOnNavigateBack(block: block)
    }
}
