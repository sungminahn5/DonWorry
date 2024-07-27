//
//  SpendingEntry.swift
//  DonWorry
//
//  Created by Sungmin Ahn on 7/25/24.
//

import SwiftUI

struct SpendingEntry: Identifiable, Codable {
    var id = UUID()
    var amount: Double
    var storeName: String
    var date: Date
    var notes: String
    var recurringPayment: Bool
    var category: String
    var receiptPhoto: Data? // Use Data to store image as binary data
    
    // Custom Coding Keys, optional if property names match JSON keys
    enum CodingKeys: String, CodingKey {
        case id, amount, storeName, date, notes, recurringPayment, category, receiptPhoto
    }
}

