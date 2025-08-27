import SwiftUI

struct TodoView: View {
    @StateObject private var viewModel = TodoViewModel()
    @State private var newTask: String = ""
    
    // Define the peachy orange-red gradient
    let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 1.0, green: 0.8, blue: 0.6),  // Light peach
            Color(red: 0.9, green: 0.4, blue: 0.3)   // Orange-red
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        NavigationView {
            ZStack {
                // Apply the gradient background
                backgroundGradient
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    HStack {
                        TextField("Add a new task...", text: $newTask)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.custom("Menlo", size: 16))  // Monospace font
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(8)
                        
                        Button(action: {
                            if !newTask.isEmpty {
                                viewModel.addItem(title: newTask)
                                newTask = ""
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding()
                    
                    List {
                        ForEach(viewModel.items) { item in
                            HStack {
                                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(Color(red: 0.7, green: 0.2, blue: 0.1))  // Darker red
                                    .onTapGesture {
                                        viewModel.toggleCompletion(of: item)
                                    }
                                
                                Text(item.title)
                                    .font(.custom("Menlo", size: 16))  // Monospace font
                                    .strikethrough(item.isCompleted)
                                    .foregroundColor(item.isCompleted ? .gray : .black)
                            }
                            .listRowBackground(Color.white.opacity(0.5))  // Semi-transparent white
                        }
                        .onDelete(perform: viewModel.deleteItem)
                    }
                    .background(Color.clear)  // Make list background transparent
                    .scrollContentBackground(.hidden)  // Hide default list background
                }
            }
            .navigationTitle("To-Do List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                EditButton()
            }
        }
    }
}
