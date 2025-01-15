import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct AddTransactionView: View {
    @Environment(\.dismiss) var dismiss
    let bandId: String
    
    @State private var amount = ""
    @State private var description = ""
    @State private var category: Finance.Category = .expense
    @State private var date = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 20, weight: .bold))
                    
                    TextField("Description", text: $description)
                        .textInputAutocapitalization(.sentences)
                    
                    Picker("Category", selection: $category) {
                        ForEach(Finance.Category.allCases, id: \.self) { category in
                            Label(category.rawValue, systemImage: categoryIcon(for: category))
                                .tag(category)
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
                        .bold()
                        .disabled(amount.isEmpty || description.isEmpty)
                }
            }
        }
    }
    
    private func saveTransaction() {
        guard let userId = Auth.auth().currentUser?.uid,
              let amountDouble = Double(amount) else { return }
        
        Task {
            try? await FinanceService.shared.addTransaction(
                description: description,
                amount: amountDouble,
                category: category,
                date: date,
                bandId: bandId,
                addedBy: userId
            )
            dismiss()
        }
    }
    
    private func categoryIcon(for category: Finance.Category) -> String {
        switch category {
        case .income: return "arrow.down.circle.fill"
        case .expense: return "arrow.up.circle.fill"
        case .equipment: return "guitars.fill"
        case .travel: return "car.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
}
