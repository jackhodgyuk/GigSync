import SwiftUI
import FirebaseFirestore

struct FinanceView: View {
    let bandId: String
    @State private var transactions: [Transaction] = []
    @State private var showingAddTransaction = false
    @State private var selectedTimeFrame: TimeFrame = .month
    
    private let db = Firestore.firestore()
    
    var body: some View {
        List {
            Section {
                Picker("Time Frame", selection: $selectedTimeFrame) {
                    ForEach(TimeFrame.allCases) { timeFrame in
                        Text(timeFrame.rawValue).tag(timeFrame)
                    }
                }
                .pickerStyle(.segmented)
                
                FinanceSummaryView(transactions: transactions)
            }
            
            Section("Recent Transactions") {
                ForEach(transactions) { transaction in
                    TransactionRow(transaction: transaction)
                }
            }
        }
        .navigationTitle("Finances")
        .toolbar {
            Button(action: { showingAddTransaction.toggle() }) {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $showingAddTransaction) {
            AddTransactionView(bandId: bandId)
        }
        .onChange(of: selectedTimeFrame) { oldValue, newValue in
            setupTransactionsListener()
        }
        .onAppear {
            setupTransactionsListener()
        }
    }
    
    private func setupTransactionsListener() {
        let startDate = selectedTimeFrame.startDate
        
        db.collection("transactions")
            .whereField("bandId", isEqualTo: bandId)
            .whereField("date", isGreaterThan: startDate)
            .order(by: "date", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                transactions = documents.compactMap { try? $0.data(as: Transaction.self) }
            }
    }
}
