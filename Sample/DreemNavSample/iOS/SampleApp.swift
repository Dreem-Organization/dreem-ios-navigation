import SwiftUI
import DreemNav

struct Route {
    let name: String
    let arguments: [String : Any]
    
    init(name: String, arguments: [String : Any] = [:]) {
        self.name = name
        self.arguments = arguments
    }
    
    static let Splash = Route(name: "Splash")
    static let Home = Route(name: "Home")
    static let FirstName = Route(name: "FirstName")
    static func LastName(firstName: String) -> Route {
        Route(name: "LastName", arguments: ["first_name":firstName])
    }
}

@main
struct SampleApp: App {
    @ObservedObject var controller =
        NavController(
            root: Route.Splash.name
        ) { graph in
            graph.screen("Splash") { SplashScreen() }
            graph.screen("Home") { HomeScreen() }
            graph.screen("FirstName") { FirstNameScreen() }
            graph.screen("LastName") { navParams in
                let firstName = navParams["first_name"] as! String
                LastNameScreen(firstName: firstName)
            }
            
            graph.screen("ConfirmationDialog") { navParams in
                if let onClickNo = navParams["onClickNo"] as? () -> Void ,
                   let onClickYes = navParams["onClickYes"] as? () -> Void {
                    ConfirmationDialog(onClickNo: onClickNo, onClickYes: onClickYes)
                }
            }
        }
    
    init() {
        register(
            assemblies: [ AppAssembly(navController: self.controller) ]
        )
    }
    
    var body: some Scene {
        WindowGroup {
            NavHost(controller: controller)
                .background(.clear)
                .preferredColorScheme(.dark)
                .clipped()
        }
    }
}
