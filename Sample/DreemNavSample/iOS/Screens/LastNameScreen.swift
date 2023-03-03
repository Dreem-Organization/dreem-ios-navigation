import SwiftUI
import DreemNav

struct LastNameScreen: View {
    let firstName: String
    var body: some View {
        LastNameContent(firstName: self.firstName)
    }
}

struct LastNameContent: View {
    
    @ObservedObject private var viewModel: LastNameViewModel
    private var firstName: String { viewModel.firstName }
    private var lastName: Binding<String> {
        Binding(
            get: { viewModel.lastName },
            set: { viewModel.setLastName(value: $0) }
        )
    }
    
    init(firstName: String) {
        self.viewModel = LastNameViewModel.getInstance(with: firstName)
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack{
                Button("Get back!") { viewModel.backToFirstName() }
                    .padding()
                
                Spacer()
            }
            
            Spacer()
            
            Text("Great job \(firstName)!")
                .foregroundColor(.primaryWhite)
                .font(.system(size: 32))
                .multilineTextAlignment(.center)
                .padding()
            
            Text("Now set a last name !")
                .foregroundColor(.primaryWhite)
                .font(.system(size: 28))
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
            
            TextField("Type a last name here", text: lastName)
                .padding()
                .foregroundColor(.white)
                .padding()
                .onSubmit { viewModel.backToHome() }
            
            Spacer()
            
            Button("Go back Home!") { viewModel.backToHome() }
                .padding()
                .foregroundColor(.backgroundColor)
                .background(Color.primaryLightBlue)
                .cornerRadius(12)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(Color.backgroundColor)
        .onAppear {
            print("\nLastName appeared")
        }
        .onDisappear {
            print("\nLastName disappeared")
        }
    }


}


fileprivate class LastNameViewModel: ObservableObject {
    private static var INSTANCE: LastNameViewModel? = nil
    private var controller: NavController = resolve()
    @Published private(set) var lastName: String = ""
    private(set) var firstName: String = ""
    
    static func getInstance(with firstName: String) -> LastNameViewModel {
        if INSTANCE == nil {
            INSTANCE = LastNameViewModel()
        }
        INSTANCE!.firstName = firstName
        return INSTANCE!
    }
    
    func setLastName(value: String) { self.lastName = value }
    
    func backToFirstName() { controller.pop() }
    
    func backToHome() {
        controller.push(
            screenName: "ConfirmationDialog",
            arguments: [
                "onClickNo": { self.controller.pop() },
                "onClickYes": {
                    self.controller.pop(
                        to: "Splash",
                        arguments: [
                            "first_name": self.firstName,
                            "last_name": self.lastName,
                        ]
                    )
                }
           ],
            transition: .dialog
        )
        
        if self.lastName.isEmpty {
                controller.push(
                    screenName: "WarningDialog",
                    transition: .dialog,
                    content: {
                        WarningDialog { self.controller.pop() }
                    }
                )
        }
    }
    
}

struct LastNameScreen_Previews: PreviewProvider {
    static var previews: some View {
        LastNameContent(firstName: "John")
    }
}
