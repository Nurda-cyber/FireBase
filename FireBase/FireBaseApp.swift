import SwiftUI
import FirebaseCore

@main
struct FirebaseAppExample: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            LoginViewControllerRepresentable()
        }
    }
}


