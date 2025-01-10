//
//  AddSongView.swift
//  GigSync
//
//  Created by Jack Hodgy on 08/01/2025.
//


import SwiftUI

struct AddSongView: View {
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var duration = ""
    var onSave: (Song) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Song Details")) {
                    TextField("Song Title", text: $title)
                    
                    HStack {
                        TextField("Duration (minutes)", text: $duration)
                            .keyboardType(.numberPad)
                        Text("min")
                    }
                }
            }
            .navigationTitle("Add Song")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Add") { saveSong() }
                    .disabled(title.isEmpty || duration.isEmpty)
            )
        }
    }
    
    private func saveSong() {
        let song = Song(
            id: UUID().uuidString,
            title: title,
            duration: Int(duration) ?? 0,
            order: 0
        )
        onSave(song)
        dismiss()
    }
}
