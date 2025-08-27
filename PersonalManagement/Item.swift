//
//  Item.swift
//  PersonalManagement
//
//  Created by Zuhayr Kabir on 29/05/2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
