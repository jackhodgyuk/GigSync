//
//  BalanceCardView.swift
//  GigSync
//
//  Created by Jack Hodgy on 08/01/2025.
//


import SwiftUI

struct BalanceCardView: View {
    let balance: Double
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Current Balance")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(formattedBalance)
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(balance >= 0 ? .green : .red)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private var formattedBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "GBP"
        return formatter.string(from: NSNumber(value: balance)) ?? "£0.00"
    }
}