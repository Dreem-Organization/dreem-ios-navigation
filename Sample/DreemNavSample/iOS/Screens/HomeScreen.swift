import SwiftUI
import DreemNav

struct HomeScreen: View {
    var body: some View {
        HomeContent()
    }
}

struct HomeContent: View {
    @ObservedObject private var viewModel = HomeViewModel.getInstance()
    private var firstName: String { viewModel.firstName }
    private var lastName: String { viewModel.lastName }
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 0) {
            HStack{
                Button("Try get back!") { viewModel.backToSplash() }
                    .padding()
                
                Spacer()
            }
            Spacer()

            if !lastName.isEmpty || !firstName.isEmpty {
                HStack {
                    Text("\(firstName) \(lastName)'s")
                        .foregroundColor(.primaryWhite)
                        .font(.system(size: 12))
                        .padding()
                }
            }
            
            Text("SwiftGate")
                .foregroundColor(.primaryWhite)
                .font(.system(size: 36))
                .padding()
            
            Spacer()
            
            Text(
                "Here start your journey through the navigation library. \n\n" +
                "In the next pages we will ask for a first and a last name, which will be displayed right below!"
            )
                .foregroundColor(.primaryLightBlue)
                .bold()
                .multilineTextAlignment(.center)
                .font(.system(size: 18))
                .padding()
            
            Spacer()
            
            VStack {
                Button("Start the classic demo!") { viewModel.goToClassicDemo() }
                    .padding()
                    .foregroundColor(.backgroundColor)
                    .background(Color.primaryLightBlue)
                    .cornerRadius(12)
                    .padding()
                
                Button("Start the Modal demo!") { viewModel.goToModalDemo() }
                    .padding()
                    .foregroundColor(.backgroundColor)
                    .background(Color.primaryLightBlue)
                    .cornerRadius(12)
                    .padding()
                
            
                Button("Clear backstack") { viewModel.clearBackstack() }
                    .padding()
                    .foregroundColor(.primaryLightBlue)
                    .background(Color.backgroundColor)
                    .cornerRadius(12)
                    .padding()
            }
        
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(Color.backgroundColor)
        .onAppear {
            print("\nHome appeared")
        }
        .onDisappear {
            print("\nHome disappeared")
        }
        
    }
    
}

private class HomeViewModel: ObservableObject {
    private static var INSTANCE: HomeViewModel? = nil
    private var controller: NavController = resolve()
    @Published private(set) var firstName: String = ""
    @Published private(set) var lastName: String = ""
    
    private init() {
        controller.setOnNavigateBack { args in
            if let firstName = args["first_name"] as? String, !firstName.isEmpty {
                self.firstName = firstName
            }
            
            if let lastName = args["last_name"] as? String, !lastName.isEmpty {
                self.lastName = lastName
            }
        }
    }
    
    static func getInstance() -> HomeViewModel {
        if INSTANCE == nil {
            INSTANCE = HomeViewModel()
        }
        return INSTANCE!
    }
    
    func goToClassicDemo() {
        controller.push(
            screenName: Route.FirstName.name,
            transition: .crossDissolve
        )
    }
    
    func goToModalDemo() {
        controller.showModal(
            screenName: Route.FirstName.name
        )
    }
    
    func clearBackstack() {
        controller.clearBackstack()
    }
    
    func backToSplash() {
        controller.pop()
    }
}

struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeContent()
    }
}
