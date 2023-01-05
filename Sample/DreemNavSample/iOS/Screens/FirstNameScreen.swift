import SwiftUI
import DreemNav

struct FirstNameScreen: View {
    var body: some View {
        FirstNameContent()
    }
}

struct FirstNameContent: View {
    @ObservedObject private var viewModel = FirstNameViewModel.getInstance()
    private var firstName: Binding<String> {
        Binding(
            get: { viewModel.firstName },
            set: { viewModel.setFirstName(value: $0) }
        )
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack{
                Button("Get back!") { viewModel.backToHome() }
                    .padding()
                
                Spacer()
            }
            
            Spacer()
            
            Text("Set a first name !")
                .foregroundColor(.primaryWhite)
                .font(.system(size: 28))
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
            
            TextField("Type a first name here", text: firstName)
                .padding()
                .foregroundColor(.white)
                .padding()
                .onSubmit { viewModel.goToLastName() }
        
            Spacer()
            
            Button("Next page!") { viewModel.goToLastName() }
                .padding()
                .foregroundColor(.backgroundColor)
                .background(Color.primaryLightBlue)
                .cornerRadius(12)
                .padding()
        
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(Color.backgroundColor)
        .onAppear {
            print("\nFirstName appeared")
        }
        .onDisappear {
            print("\nFirstName disappeared")
        }
    }
    

}

private class FirstNameViewModel: ObservableObject {
    private static var INSTANCE: FirstNameViewModel? = nil
    private var controller: NavController = resolve()
    @Published private(set) var firstName: String = ""
    
    private init() {
        
    }
    
    static func getInstance() -> FirstNameViewModel {
        if INSTANCE == nil {
            INSTANCE = FirstNameViewModel()
        }
        return INSTANCE!
    }
    
    func setFirstName(value: String) { self.firstName = value }
    
    func goToLastName() {
        let destination = Route.LastName(firstName: firstName)
        controller.push(
            screenName: destination.name,
            arguments: destination.arguments
        )
    }
    
    func backToHome() {
        controller.pop(arguments: ["first_name": firstName])
    }
    
}

struct FirstNameScreen_Previews: PreviewProvider {
    static var previews: some View {
        FirstNameContent()
    }
}
