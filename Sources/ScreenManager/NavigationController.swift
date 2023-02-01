import UIKit

internal class NavigationController: UINavigationController {
    
    var onBeingDismissed: (() -> Void)? = nil
    
    init(viewController: UIViewController) {
        super.init(nibName: nil, bundle: nil)
        super.setViewControllers([viewController], animated: true)
    }
    
    func setOnViewBeingDismissed(block: (() -> Void)? = nil) {
        self.onBeingDismissed = block
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if super.isBeingDismissed {
            onBeingDismissed?()
        }
    }
    
    func safePopTo(viewController: UIViewController) {
        guard let viewController = self.viewControllers.last(where: { $0 == viewController}) else {
            return
        }
        super.popToViewController(viewController, animated: true)
    }

}
