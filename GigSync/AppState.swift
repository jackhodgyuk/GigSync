//
//  AppState.swift
//  GigSync
//
//  Created by Jack Hodgy on 15/01/2025.
//


import SwiftUI

class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var needsRefresh = false
    
    private init() {}
    
    func refresh() {
        needsRefresh = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.needsRefresh = false
        }
    }
}
