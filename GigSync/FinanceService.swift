//
//  FinanceService.swift
//  GigSync
//
//  Created by Jack Hodgy on 08/01/2025.
//


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
        let transactionData: [String: Any] = [
            "description": description,
            "amount": amount,
            "category": category.rawValue,
            "date": date,
            "bandId": bandId,
            "addedBy": addedBy,
            "createdAt": Date()
        ]
        
        try await db.collection("finances").document().setData(transactionData)
    }
    
    func getTransactionSummary(bandId: String) async throws -> [String: Double] {
        let snapshot = try await db.collection("finances")
            .whereField("bandId", isEqualTo: bandId)
            .getDocuments()
        
        var summary: [String: Double] = [:]
        
        for document in snapshot.documents {
            guard let transaction = try? document.data(as: Finance.self) else { continue }
            let categoryKey = transaction.category.rawValue
            summary[categoryKey, default: 0] += transaction.amount
        }
        
        return summary
    }
    
    func deleteTransaction(_ transactionId: String) async throws {
        try await db.collection("finances").document(transactionId).delete()
    }
}
