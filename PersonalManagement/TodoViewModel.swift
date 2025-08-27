import Foundation

class TodoViewModel: ObservableObject {
    @Published var items: [TodoItem] = []
    
    func addItem(title: String) {
        let newItem = TodoItem(title: title)
        items.append(newItem)
    }
    
    func toggleCompletion(of item: TodoItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isCompleted.toggle()
        }
    }
    
    func deleteItem(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
}
