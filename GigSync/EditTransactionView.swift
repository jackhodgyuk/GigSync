import SwiftUI
import FirebaseFirestore

struct EditTransactionView: View {
    let finance: Finance
    let bandId: String
    
    @Environment(\.dismiss) private var dismiss
    @State private var description: String
    @State private var amount: Double
    @State private var category: Finance.Category
    @State private var date: Date
    
    init(finance: Finance, bandId: String) {
        self.finance = finance
        self.bandId = bandId
        _description = State(initialValue: finance.description)
        _amount = State(initialValue: finance.amount)
        _category = State(initialValue: finance.category)
        _date = State(initialValue: finance.date)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    // Amount Card
                    VStack(spacing: 16) {
                        Text("Amount")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Amount", value: $amount, format: .currency(code: "GBP"))
                            .font(.system(size: 40, weight: .bold))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.center)
                            .padding(.vertical, 20)
                    }
                    .padding(24)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 10)
                    
                    // Category Card
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Category")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Picker("Category", selection: $category) {
                            ForEach(Finance.Category.allCases, id: \.self) { category in
                                Label(category.rawValue, systemImage: categoryIcon(for: category))
                                    .tag(category)
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 10)
                    
                    // Description Card
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Description")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("What's this for?", text: $description)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.title3)
                    }
                    .padding(24)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 10)
                    
                    // Date Card
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Date")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        DatePicker("", selection: $date, displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .tint(.blue)
                    }
                    .padding(24)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 10)
                }
                .padding(20)
                
                // Save Button
                Button(action: {
                    updateTransaction()
                    dismiss()
                }) {
                    Text("Save Changes")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .cornerRadius(16)
                        .shadow(color: .blue.opacity(0.3), radius: 10)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Edit Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
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
    
    private func updateTransaction() {
        let data: [String: Any] = [
            "description": description,
            "amount": amount,
            "category": category.rawValue,
            "date": date,
            "bandId": bandId
        ]
        
        Firestore.firestore().collection("finances")
            .document(finance.id)
            .updateData(data)
    }
}
