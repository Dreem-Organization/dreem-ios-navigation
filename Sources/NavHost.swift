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
    @ObservedObject private var controller: NavController
    
    public init(controller: NavController, backgroundColor: Color = .clear) {
        self.controller = controller
        ScreenTheme.backgroundColor = backgroundColor
    }
    
    public var body: some View {
        self.representable.background(ScreenTheme.backgroundColor.edgesIgnoringSafeArea(.all))
    }
}

private extension NavHost {
    private var representable: NavHostRepresentable {
        NavHostRepresentable(
            viewController: self.controller.screenManager.uiViewController
        )
    }
}

private struct NavHostRepresentable: UIViewControllerRepresentable {
    var viewController: UIViewController
    
    func makeUIViewController(context: Context) -> UIViewController { viewController }
    
    func updateUIViewController(_ baseViewController: UIViewController, context: Context) { }

    typealias UIViewControllerType = UIViewController
}
