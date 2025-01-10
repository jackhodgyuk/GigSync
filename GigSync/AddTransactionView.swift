import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct AddTransactionView: View {
    @Environment(\.dismiss) var dismiss
    let bandId: String
    private let db = Firestore.firestore()
    
    @State private var amount = ""
    @State private var description = ""
    @State private var category: Transaction.TransactionCategory = .expense
    @State private var date = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Transaction Details") {
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    
                    TextField("Description", text: $description)
                    
                    Picker("Category", selection: $category) {
                        ForEach(Transaction.TransactionCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    
                    DatePicker("Date", selection: $date, displayedComponents: [.date])
                }
            }
            .navigationTitle("New Transaction")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save", action: saveTransaction)
                        .disabled(amount.isEmpty || description.isEmpty)
                }
            }
        }
    }
    
    private func saveTransaction() {
        guard let userId = Auth.auth().currentUser?.uid,
              let amountDouble = Double(amount) else { return }
        
        let transaction = Transaction(
            id: UUID().uuidString,
            amount: amountDouble,
            description: description,
            category: category,
            date: date,
            bandId: bandId,
            createdBy: userId
        )
        
        Task {
            let data = try JSONEncoder().encode(transaction)
            let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
            try await db.collection("transactions").document(transaction.id).setData(dict)
            dismiss()
        }
    }
}

enum TransactionError: Error {
    case invalidInput
}
