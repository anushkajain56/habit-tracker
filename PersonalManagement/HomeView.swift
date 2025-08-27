import SwiftUI

struct HomeView: View {
    @Binding var isAppStarted: Bool

    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to the App")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Your personal management assistant.")
                .font(.title3)
                .foregroundColor(.gray)

            Button(action: {
                isAppStarted = true
            }) {
                Text("Get Started")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
    }
}
