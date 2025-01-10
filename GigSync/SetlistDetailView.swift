//
//  SetlistDetailView.swift
//  GigSync
//
//  Created by Jack Hodgy on 08/01/2025.
//


import SwiftUI
import FirebaseFirestore

struct SetlistDetailView: View {
    @State private var setlist: Setlist
    @State private var showingAddSong = false
    @State private var isEditing = false
    
    init(setlist: Setlist) {
        _setlist = State(initialValue: setlist)
    }
    
    var body: some View {
        List {
            Section(header: Text("Details")) {
                HStack {
                    Text("Total Duration:")
                    Spacer()
                    Text("\(setlist.duration) minutes")
                        .foregroundColor(.secondary)
                }
            }
            
            Section(header: Text("Songs")) {
                ForEach(setlist.songs) { song in
                    SongRowView(song: song)
                }
                .onMove(perform: moveSongs)
                .onDelete(perform: deleteSong)
            }
        }
        .navigationTitle(setlist.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddSong.toggle() }) {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
        .sheet(isPresented: $showingAddSong) {
            AddSongView { song in
                addSong(song)
            }
        }
    }
    
    private func moveSongs(from source: IndexSet, to destination: Int) {
        var updatedSongs = setlist.songs
        updatedSongs.move(fromOffsets: source, toOffset: destination)
        
        for (index, _) in updatedSongs.enumerated() {
            updatedSongs[index].order = index
        }
        
        Task {
            try? await SetlistService.shared.updateSongOrder(
                setlistId: setlist.id,
                songs: updatedSongs
            )
        }
    }
    
    private func deleteSong(at offsets: IndexSet) {
        Task {
            try? await SetlistService.shared.removeSongs(
                from: setlist.id,
                at: offsets
            )
        }
    }
    
    private func addSong(_ song: Song) {
        Task {
            try? await SetlistService.shared.addSong(
                to: setlist.id,
                song: song
            )
        }
    }
}
