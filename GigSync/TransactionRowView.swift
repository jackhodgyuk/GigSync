import SwiftUI

struct TransactionRowView: View {
    let transaction: Finance
    
    var body: some View {
        HStack(spacing: 16) {
            // Category Icon
            Image(systemName: categoryIcon(for: transaction.category))
                .font(.system(size: 24))
                .foregroundColor(categoryColor(for: transaction.category))
                .frame(width: 40, height: 40)
                .background(categoryColor(for: transaction.category).opacity(0.1))
                .clipShape(Circle())
            
            // Transaction Details
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.description)
                    .font(.headline)
                
                HStack {
                    Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                    Text("•")
                    Text(transaction.category.rawValue)
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Amount
            Text(transaction.formattedAmount)
                .font(.system(.headline, design: .rounded))
                .foregroundColor(transaction.category == .income ? .green : .red)
        }
        .padding(.vertical, 8)
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
    
    private func categoryColor(for category: Finance.Category) -> Color {
        switch category {
        case .income: return .green
        case .expense: return .red
        case .equipment: return .blue
        case .travel: return .orange
        case .other: return .purple
        }
    }
}
