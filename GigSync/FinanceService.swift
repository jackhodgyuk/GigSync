import FirebaseFirestore

class FinanceService {
    static let shared = FinanceService()
    private let db = Firestore.firestore()
    
    func addTransaction(
        description: String,
        amount: Double,
        category: Finance.Category,
        date: Date,
        bandId: String,
        addedBy: String
    ) async throws {
        let id = UUID().uuidString
        let finance = Finance(
            id: id,
            description: description,
            amount: amount,
            date: date,
            category: category,
            bandId: bandId,
            addedBy: addedBy
        )
        
        try await db.collection("finances").document(id).setData([
            "id": finance.id,
            "description": finance.description,
            "amount": finance.amount,
            "date": finance.date,
            "category": finance.category.rawValue,
            "bandId": finance.bandId,
            "addedBy": finance.addedBy,
            "createdAt": Date()
        ])
    }
    
    func getTransactions(bandId: String) async throws -> [Finance] {
        let snapshot = try await db.collection("finances")
            .whereField("bandId", isEqualTo: bandId)
            .order(by: "date", descending: true)
            .getDocuments()
            
        return snapshot.documents.compactMap { try? $0.data(as: Finance.self) }
    }
    
    func deleteTransaction(_ transactionId: String) async throws {
        try await db.collection("finances").document(transactionId).delete()
    }
    
    func getTransactionSummary(bandId: String) async throws -> [String: Double] {
        let transactions = try await getTransactions(bandId: bandId)
        
        return Dictionary(grouping: transactions, by: { $0.category.rawValue })
            .mapValues { transactions in
                transactions.reduce(0) { $0 + $1.amount }
            }
    }
}
