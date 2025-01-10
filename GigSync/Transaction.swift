//
//  Transaction.swift
//  GigSync
//
//  Created by Jack Hodgy on 08/01/2025.
//


import Foundation

struct Transaction: Identifiable, Codable {
    let id: String
    let amount: Double
    let description: String
    let category: TransactionCategory
    let date: Date
    let bandId: String
    let createdBy: String
    
    enum TransactionCategory: String, Codable, CaseIterable {
        case income = "Income"
        case expense = "Expense"
    }
}
