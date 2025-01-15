import SwiftUI
import FirebaseFirestore

struct FinanceView: View {
    let bandId: String
    @State private var finances: [Finance] = []
    @State private var showingAddTransaction = false
    @State private var selectedTimeFrame: TimeFrame = .month
    
    private var totalIncome: Double {
        finances.filter { $0.category == .income }.reduce(0) { $0 + $1.amount }
    }
    
    private var totalExpenses: Double {
        finances.filter { $0.category != .income }.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Summary Cards
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        SummaryCard(
                            title: "Income",
                            amount: totalIncome,
                            color: .green
                        )
                        
                        SummaryCard(
                            title: "Expenses",
                            amount: totalExpenses,
                            color: .red
                        )
                        
                        SummaryCard(
                            title: "Balance",
                            amount: totalIncome - totalExpenses,
                            color: .blue
                        )
                    }
                    .padding()
                }
                
                // Time Frame Picker
                Picker("Time Frame", selection: $selectedTimeFrame) {
                    ForEach(TimeFrame.allCases) { timeFrame in
                        Text(timeFrame.rawValue).tag(timeFrame)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Transactions List
                List {
                    ForEach(finances) { finance in
                        TransactionRowView(transaction: finance)
                    }
                }
            }
            .navigationTitle("Finances")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTransaction.toggle() }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showingAddTransaction) {
                AddTransactionView(bandId: bandId)
            }
        }
        .onAppear {
            setupFinancesListener()
        }
    }
    
    private func setupFinancesListener() {
        let startDate = selectedTimeFrame.startDate
        
        Firestore.firestore().collection("finances")
            .whereField("bandId", isEqualTo: bandId)
            .whereField("date", isGreaterThan: startDate)
            .order(by: "date", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                finances = documents.compactMap { try? $0.data(as: Finance.self) }
            }
    }
}
