//
//  FinanceManagementView.swift
//  GigSync
//
//  Created by Jack Hodgy on 08/01/2025.
//


import SwiftUI
import FirebaseFirestore

struct FinanceManagementView: View {
    @State private var transactions: [Finance] = []
    @State private var showingAddTransaction = false
    @State private var selectedFilter: Finance.Category?
    let bandId: String
    
    var filteredTransactions: [Finance] {
        guard let filter = selectedFilter else { return transactions }
        return transactions.filter { $0.category == filter }
    }
    
    var totalBalance: Double {
        transactions.reduce(0) { total, transaction in
            total + (transaction.category == .income ? transaction.amount : -transaction.amount)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Balance Card
                BalanceCardView(balance: totalBalance)
                    .padding()
                
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        CategoryFilterButton(title: "All", isSelected: selectedFilter == nil) {
                            selectedFilter = nil
                        }
                        
                        ForEach(Finance.Category.allCases, id: \.self) { category in
                            CategoryFilterButton(
                                title: category.rawValue,
                                isSelected: selectedFilter == category
                            ) {
                                selectedFilter = category
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Transactions List
                List {
                    ForEach(filteredTransactions) { transaction in
                        TransactionRowView(transaction: transaction)
                    }
                }
            }
            .navigationTitle("Finances")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTransaction.toggle() }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTransaction) {
                AddTransactionView(bandId: bandId)
            }
        }
        .onAppear {
            setupTransactionsListener()
        }
    }
    
    private func setupTransactionsListener() {
        Firestore.firestore().collection("finances")
            .whereField("bandId", isEqualTo: bandId)
            .order(by: "date", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                transactions = documents.compactMap { try? $0.data(as: Finance.self) }
            }
    }
}
