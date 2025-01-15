import SwiftUI
import FirebaseFirestore

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
                trailing: Button("Add") {
                    let song = SongService.shared.createLocalSong(
                        title: title,
                        duration: Int(duration) ?? 0
                    )
                    onSave(song)
                    dismiss()
                }
                .disabled(title.isEmpty || duration.isEmpty)
            )
        }
    }
}
