import SwiftUI
import FirebaseFirestore

struct AddSongView: View {
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var duration = ""
    let setlistId: String
    let bandId: String
    @State private var isLoading = false
    
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
                trailing: Button("Add") {
                    Task {
                        await saveSong()
                    }
                }
                .disabled(title.isEmpty || duration.isEmpty || isLoading)
            )
        }
    }
    
    private func saveSong() async {
        isLoading = true
        do {
            let songId = try await SongService.shared.addSong(
                title: title,
                artist: "",
                duration: Int(duration) ?? 0,
                key: nil,
                bandId: bandId
            )
            
            let song = Song(
                id: songId,
                title: title,
                duration: Int(duration) ?? 0,
                order: 0
            )
            
            try await SetlistService.shared.addSong(to: setlistId, song: song)
            onSave(song)
            dismiss()
        } catch {
            print("Error saving song: \(error)")
        }
        isLoading = false
    }
}
