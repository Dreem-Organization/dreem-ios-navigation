import SwiftUI

private struct ScreenBuilder {
    let name: String
    @ViewBuilder let builder: ([String: Any]) -> AnyView
}

/// A type alias for the DreemNav framework’s type for a lambda that takes `NavGraph` as entry parameter.
public typealias NavGraphBuilder = (NavGraph) -> Void

public class NavGraph {
    private var screenBuilders: [ScreenBuilder] = []
    
    /// Adds a new screen builder to the `NavGraph`.
    ///
    /// Use this method to  generate a new `ScreenBuilder` embedding a ViewBuilder that needs arguments to be built, and add it to the mutable array `screenBuilders`.
    /// Here is an example related to the use of `NavGraph` into the SampleApp :
    /// ```
    ///    NavController(
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
    /// As you can see here we've added four new way to build screens into the `NavGraph`.
    /// The one that uses this function is :
    /// ```
    ///            graph.screen("LastName") { navParams in
    ///                let firstName = navParams["first_name"] as! String
    ///                LastNameScreen(firstName: firstName)
    ///            }
    /// ```
    /// See also ``NavController/push(screenName:arguments:transition:asNewRoot:)`` to look how parameters are passed through a `push` navigation.
    ///
    /// - Parameters:
    ///     - name: The name of the screen which will be used for the navigation.
    ///     - contentBuilder: This ViewBuilder defines how the screen will be generated, the dictionary passed as entry parameter works as an arguments map.
    public func screen(_ name: String, @ViewBuilder contentBuilder: @escaping ([String: Any]) -> some View) {
        guard !self.screenBuilders.contains(where: { $0.name == name }) else {
            print("NavGraph/screen(\(name), contentBuilder:_) • Could not add \"\(name)\" as it already exists.")
            print("Names must be unique.")
            return
        }
        
        self.screenBuilders.append(
            ScreenBuilder(name: name) { AnyView(contentBuilder($0)) }
        )
    }
    
    /// Adds a new screen builder to the `NavGraph`.
    ///
    /// Use this method to  generate a new `ScreenBuilder` embedding a ViewBuilder and add it to the mutable array `screenBuilders`.
    /// Here is an example related to the use of `NavGraph` into the SampleApp :
    /// ```
    ///    NavController(
    ///            root: Route.Splash.name
    ///        ) { graph in
    ///            graph.screen("Splash") { SplashScreen() }
    ///            graph.screen("Home") { HomeScreen() }
    ///            graph.screen("FirstName") { FirstNameScreen() }
    ///        }
    /// ```
    /// As you can see here we've added three new way to build screens into the `NavGraph`.
    ///
    /// - Parameters:
    ///     - name: The name of the screen which will be used for the navigation.
    ///     - contentBuilder: This ViewBuilder defines how the screen will be generated.
    public func screen(_ name: String, @ViewBuilder contentBuilder: @escaping () -> some View) {
        self.screen(name) { _ in contentBuilder() }
    }
    
    internal func buildScreen(from screenName: String, and arguments: [String: Any] = [:]) -> Screen? {
        guard let view = self.screenBuilders.first(where: { $0.name == screenName })?.builder(arguments) else {
            print("NavGraph/getView(from: \(screenName), and: \(arguments)) • Could not retreive any view named \"\(screenName)\".")
            print("Available screens at this time :\(screenBuilders.listString { $0.name })")
            return nil
        }
        return Screen(name: screenName, arguments: arguments, view: view)
    }
}
