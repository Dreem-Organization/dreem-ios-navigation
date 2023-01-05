import SwiftUI
import DreemNav

struct SplashScreen: View {
    var body: some View {
        SplashContent()
    }
}

struct SplashContent: View {
    @ObservedObject private var viewModel = SplashViewModel.getInstance()
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 0) {
            Spacer()

            Text("Splash")
                .foregroundColor(.primaryWhite)
                .font(.system(size: 36))
                .padding()
            
            Spacer()
            
            Button("Go Home") { viewModel.goToHome(newRoot: false) }
                .padding()
                .foregroundColor(.backgroundColor)
                .background(Color.primaryLightBlue)
                .cornerRadius(12)
                .padding()
            
        
            Spacer()
            
            Button("Go Home (and clear backstack)") { viewModel.goToHome(newRoot: true) }
                .padding()
                .foregroundColor(.backgroundColor)
                .background(Color.primaryLightBlue)
                .cornerRadius(12)
                .padding()
            
        
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(Color.backgroundColor)
        .onAppear {
            print("\nSplash appeared")
        }
        .onDisappear {
            print("\nSplash disappeared")
        }
        
    }
    
}

private class SplashViewModel: ObservableObject {
    private static var INSTANCE: SplashViewModel? = nil
    private var controller: NavController = resolve()
    
    private init() {
        
    }
    
    static func getInstance() -> SplashViewModel {
        if INSTANCE == nil {
            INSTANCE = SplashViewModel()
        }
        return INSTANCE!
    }
    
    func goToHome(newRoot: Bool) {
        controller.push(
            screenName: Route.Home.name,
            asNewRoot: newRoot
        )
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeContent()
    }
}
