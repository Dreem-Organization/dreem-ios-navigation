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
    /// // screenStack : ScreenA, ScreenB, ScreenC and ScreenD.
    ///
    /// controller.clearBackstack()
    ///
    /// // screenStack : ScreenD
    /// ```
    /// When a sheet is presented and ``NavController/clearBackstack()`` is called the sheet dismiss,
    /// then each screen following the sheet are removed from the `screenStack`,
    /// finally the latest screen before the sheet becomes the top view displayed.
    /// ```
    /// // screenStack : ScreenA, ScreenB, SheetA and SheetB.
    ///
    /// controller.clearBackstack()
    ///
    /// // screenStack : ScreenB
    /// ```
    ///
    public func clearBackstack() {
        screenManager.clearBackstack()
    }
    
    /// Display a screen that was shown previously into the hierarchy.
    ///
    /// Use this method to remove one or many screens from the backstack.
    /// ```
    /// // screenStack : ScreenA, ScreenB, ScreenC and ScreenD.
    ///
    /// controller.pop()
    ///
    /// // screenStack : ScreenA, ScreenB and ScreenC
    ///
    /// controller.pop(to: "ScreenB", inclusive: true)
    ///
    /// // screenStack : ScreenA
    /// ```
    /// As you can see in the above example, as we are using `ScreenB` as target destination with `inclusive` parameter.
    /// Each screen shown after `ScreenB` included are erased from screenStack.
    ///
    /// - Parameters:
    ///     - screenName: This `String?` allows you to navigate back to a chosen screen by entering its name.
    ///     - inclusive: The targetted screen is also popped out of the stack.
    ///     - arguments: This `Dictionary` holds, under its key/value pairs, data that you want to share with the popped screen.
    public func pop(to screenName: String? = nil, inclusive: Bool = false, arguments: [String : Any] = [:]) {
        screenManager.pop(to: screenName, inclusive: inclusive, arguments: arguments)
    }
    
    /// Push a new screen to the backstack.
    ///
    /// Use this method to add a screen to the last navigation contexts stack.
    /// ```
    /// // screenStack : ScreenA, ScreenB and ScreenC.
    ///
    /// controller.push(screenName: "SheetA", transition: .sheet)
    ///
    /// // screenStack : ScreenA, ScreenB, ScreenC and SheetA.
    ///
    /// ```
    /// Depending the parameters used, the screen could be the only one in the stack.
    /// ```
    /// // screenStack : ScreenA, ScreenB and ScreenC.
    ///
    /// controller.push(screenName: "ScreenD", asNewRoot: true)
    ///
    /// // screenStack : ScreenD
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
        arguments: [String : Any] = [:],
        transition: TransitionStyle = .coverHorizontal,
        asNewRoot: Bool = false
    ) {
        screenManager.push(screenName: screenName, arguments: arguments, transition: transition, asNewRoot: asNewRoot)
    }
    
    /// Push a new screen to the backstack.
    ///
    /// Use this method to add a screen to the last navigation contexts stack.
    /// ```
    /// // screenStack : ScreenA, ScreenB and ScreenC.
    ///
    /// controller.push(screenName: "DialogA", transition: .dialog) {
    ///     Text("I am DialogA")
    /// }
    ///
    /// // screenStack : ScreenA, ScreenB, ScreenC and DialogA.
    /// ```
    /// Depending the parameters used, the screen could be the only one in the stack.
    /// ```
    /// // screenStack : ScreenA, ScreenB and ScreenC.
    ///
    /// controller.push(screenName: "ScreenD", asNewRoot: true) {
    ///     Text("I am ScreenD")
    /// }
    ///
    /// // screenStack : ScreenD
    /// ```
    /// If the controller cannot find any related view from the graph, console will prompt logs.
    ///
    /// - Parameters:
    ///     - screenName: The name of the screen that will be used to retrieve a ViewBuilding from the `NavGraph`.
    ///     - transition: Sets the animation that will be triggered.
    ///     - asNewRoot: Indicate wheter or not the pushed destination will become root.
    ///     - content: This `() -> some View` closure defines the screen that you want to see displayed.
    public func push(
        screenName: String,
        transition: TransitionStyle = .coverHorizontal,
        asNewRoot: Bool = false,
        @ViewBuilder content: () -> some View
    ) {
        screenManager.push(screenName: screenName, transition: transition, asNewRoot: asNewRoot, content: content)
    }
    
    /// Saves back navigation instructions
    ///
    /// When ``NavController/setOnNavigateBack(block:)`` is called, the instructions
    /// are linked to the calling screen, whenever we navigate back to it, the lambda contained into the closure is triggered.
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
    ///     - block: This lambda defines the instructions to execute on a back navigation to the calling screen, the dictionary passed as entry parameter works as an arguments map.
    public func setOnNavigateBack(block: @escaping ([String : Any]) -> Void) {
        screenManager.setOnNavigateBack(block: block)
    }
}
