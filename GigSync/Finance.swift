//
//  Finance.swift
//  GigSync
//
//  Created by Jack Hodgy on 08/01/2025.
//


import Foundation

struct Finance: Identifiable, Codable {
    let id: String
    let description: String
    let amount: Double
    let date: Date
    let category: Category
    let bandId: String
    let addedBy: String
    
    enum Category: String, Codable, CaseIterable {
        case income = "Income"
        case expense = "Expense"
        case equipment = "Equipment"
        case travel = "Travel"
        case other = "Other"
    }
    
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "GBP"
        return formatter.string(from: NSNumber(value: amount)) ?? "£0.00"
    }
}
