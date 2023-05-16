import SwiftUI

internal class Screen: UIHostingController<AnyView>, Identifiable {
    let id: UUID = UUID()
    let name: String
    var onNavigateTo: ([String : Any]) -> Void = { _ in }

    init(
        name: String,
        backgroundColor: Color?,
        view: some View
    ) {
        self.name = name
        super.init(rootView: AnyView(view))
        if let backgroundColor = backgroundColor {
            self.view.backgroundColor = UIColor(backgroundColor)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
