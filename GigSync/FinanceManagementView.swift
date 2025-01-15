import SwiftUI
import FirebaseFirestore

struct FinanceManagementView: View {
    let bandId: String
    @State private var finances: [Finance] = []
    @State private var showingAddTransaction = false
    @State private var selectedFilter: Finance.Category?
    
    var filteredTransactions: [Finance] {
        guard let filter = selectedFilter else { return finances }
        return finances.filter { $0.category == filter }
    }
    
    var totalBalance: Double {
        finances.reduce(0) { total, finance in
            if finance.category == .income {
                return total + finance.amount
            } else {
                return total - finance.amount
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Balance Card
                VStack {
                    Text("Total Balance")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text(formatCurrency(totalBalance))
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(totalBalance >= 0 ? .green : .red)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemBackground))
                .shadow(radius: 2)
                
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FilterButton(title: "All", isSelected: selectedFilter == nil) {
                            selectedFilter = nil
                        }
                        
                        Button(action: { showingAddTransaction.toggle() }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        
                        ForEach(Finance.Category.allCases, id: \.self) { category in
                            FilterButton(
                                title: category.rawValue,
                                isSelected: selectedFilter == category
                            ) {
                                selectedFilter = category
                            }
                        }
                    }
                    .padding()
                }
                
                // Transactions List
                List {
                    ForEach(filteredTransactions) { finance in
                        NavigationLink {
                            EditTransactionView(finance: finance, bandId: bandId)
                        } label: {
                            TransactionRowView(transaction: finance)
                        }
                    }
                    .onDelete { indexSet in
                        let financesToDelete = indexSet.map { filteredTransactions[$0] }
                        for finance in financesToDelete {
                            Firestore.firestore().collection("finances")
                                .document(finance.id)
                                .delete()
                        }
                    }
                }
            }
            .navigationTitle("Finances")
            .sheet(isPresented: $showingAddTransaction) {
                AddTransactionView(bandId: bandId)
            }
        }
        .onAppear {
            setupFinancesListener()
        }
    }
    
    private func setupFinancesListener() {
        Firestore.firestore().collection("finances")
            .whereField("bandId", isEqualTo: bandId)
            .order(by: "date", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                finances = documents.compactMap { try? $0.data(as: Finance.self) }
            }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "GBP"
        return formatter.string(from: NSNumber(value: amount)) ?? "£0.00"
    }
}

private struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}
