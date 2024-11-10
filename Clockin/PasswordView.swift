import SwiftUI

struct PasswordView: View {
    @State private var password: String = ""
    @State private var isAuthenticated: Bool = false

    var body: some View {
        VStack {
            if isAuthenticated {
                ProtectedView()
            } else {
                TextField("Enter Password", text: $password)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad) // Set the keyboard type to number pad
                Button(action: {
                    if self.password == "1234" { // Replace with your password
                        self.isAuthenticated = true
                    }
                }) {
                    Text("Submit")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
    }
}