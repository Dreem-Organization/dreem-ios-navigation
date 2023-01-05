import SwiftUI

internal class Screen: UIHostingController<AnyView>, Identifiable {
    let id: UUID = UUID()
    let name: String
    let arguments: [String: Any]
    var onNavigateTo: ([String: Any]) -> Void = { _ in }
    
    init(
        name: String,
        arguments: [String: Any] = [:],
        view: some View
    ) {
        self.name = name
        self.arguments = arguments
        super.init(rootView: AnyView(view))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

internal enum PresentationMode {
    case sheet, fullScreen
}
