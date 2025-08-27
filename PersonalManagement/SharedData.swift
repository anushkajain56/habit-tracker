// SharedData.swift
import Foundation

class SharedData: ObservableObject {
    @Published var todoItems: [TodoItem] = []
}
