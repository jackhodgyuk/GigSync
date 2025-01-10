//
//  BandMember.swift
//  GigSync
//
//  Created by Jack Hodgy on 08/01/2025.
//


import Foundation

struct BandMember: Identifiable {
    let id: String
    let name: String
    let email: String
    let role: String
    
    var isAdmin: Bool {
        role == "admin"
    }
    
    var isManager: Bool {
        role == "manager"
    }
    
    var canEditContent: Bool {
        isAdmin || isManager
    }
}
