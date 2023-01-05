import Swinject
import DreemNav

class AppAssembly: Assembly {
    
    private let navController: NavController
    
    init(navController: NavController) {
        self.navController = navController
    }
    
    func assemble(container: Container) {
        container.register(NavController.self) { _ in self.navController }.inObjectScope(.container)
    }
    
}
