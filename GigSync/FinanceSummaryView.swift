//
//  FinanceSummaryView.swift
//  GigSync
//
//  Created by Jack Hodgy on 08/01/2025.
//


import SwiftUI

struct FinanceSummaryView: View {
    let transactions: [Transaction]
    
    private var income: Double {
        transactions
            .filter { $0.category == .income }
            .reduce(0) { $0 + $1.amount }
    }
    
    private var expenses: Double {
        transactions
            .filter { $0.category == .expense }
            .reduce(0) { $0 + $1.amount }
    }
    
    private var balance: Double {
        income - expenses
    }
    
    var body: some View {
        VStack(spacing: 16) {
            SummaryCard(title: "Income", amount: income, color: .green)
            SummaryCard(title: "Expenses", amount: expenses, color: .red)
            SummaryCard(title: "Balance", amount: balance, color: balance >= 0 ? .blue : .red)
        }
        .padding()
    }
}
