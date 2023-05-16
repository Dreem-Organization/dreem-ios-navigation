import SwiftUI

/// A type that represents the entry point of your app navigation.
///```
///    var body: some Scene {
///        WindowGroup {
///            NavHost(controller: controller)
///        }
///    }
///```
///
/// Once ``NavHost`` is called, each screen declared into ``NavGraphBuilder``
/// can be navigated to using the ``NavController`` that holds the builder.
///
/// As ``NavHost`` extends the `View` protocol, a set of modifiers
/// are provided, as described in `Configuring-Views`.
/// For example, adding the ``View/background(_)`` modifier :
///
///     NavHost(controller: controller)
///                .background(.clear) // Display .clear background set.
///
/// The complete list of default modifiers provides a large set of controls
/// for managing this view.
public struct NavHost: View {
    @ObservedObject
    private var controller: NavController
    
    public init(controller: NavController, backgroundColor: Color) {
        self.controller = controller
        self.controller.backgroundColor = UIColor(backgroundColor)
    }
    
    public var body: some View {
        EmptyView()
            .onAppear {
                if controller.viewController == nil {
                    controller.viewController = window?.rootViewController
                }
            }
    }
    
    private var window: UIWindow? {
        guard let scene = UIApplication.shared.connectedScenes.first,
              let windowSceneDelegate = scene.delegate as? UIWindowSceneDelegate,
              let window = windowSceneDelegate.window else {
            return nil
        }
        return window
    }
}
