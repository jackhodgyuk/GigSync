//
//  AttendanceStatus.swift
//  GigSync
//
//  Created by Jack Hodgy on 11/01/2025.
//


import SwiftUI
import FirebaseFirestore

enum AttendanceStatus: String, CaseIterable, Codable {
    case attending = "Going"
    case notAttending = "Not Going"
    case pending = "Pending"
    
    var color: Color {
        switch self {
        case .attending: return .green
        case .notAttending: return .red
        case .pending: return .orange
        }
    }
}

struct Attendance: Codable {
    let userId: String
    let status: AttendanceStatus
    let timestamp: Date
}

extension Data {
    func asDict() throws -> [String: Any] {
        try JSONSerialization.jsonObject(with: self, options: .allowFragments) as? [String: Any] ?? [:]
    }
}
