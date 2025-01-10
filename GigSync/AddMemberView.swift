import SwiftUI
import FirebaseFirestore

struct AddMemberView: View {
    let bandId: String
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    @State private var searchResults: [User] = []
    
    var body: some View {
        NavigationView {
            List {
                ForEach(searchResults) { user in
                    UserRow(user: user) {
                        addMember(userId: user.id ?? "")
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search by email or name")
            .onChange(of: searchText) { oldValue, newValue in
                searchUsers()
            }
            .navigationTitle("Add Member")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
    
    private func searchUsers() {
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }
        
        Task {
            if let users = try? await UserService.shared.searchUsers(query: searchText) {
                await MainActor.run {
                    searchResults = users.filter { $0.id != nil }
                }
            }
        }
    }
    
    private func addMember(userId: String) {
        Task {
            try? await BandService.shared.addMemberToBand(userId: userId, bandId: bandId)
            await MainActor.run {
                dismiss()
            }
        }
    }
}
