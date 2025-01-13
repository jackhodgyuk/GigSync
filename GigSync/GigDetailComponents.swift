//
//  GigDetail.swift
//  GigSync
//
//  Created by Jack Hodgy on 11/01/2025.
//

import SwiftUI

struct DetailCard: View {
    let gig: Gig
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Details")
                .font(.headline)
            
            HStack {
                Image(systemName: "mappin.circle")
                Text(gig.venue)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct NotesCard: View {
    let notes: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notes")
                .font(.headline)
            Text(notes)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct SetlistCard: View {
    @Binding var showPicker: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Setlist")
                .font(.headline)
            Button("Manage Setlist") {
                showPicker = true
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct AttendanceButton: View {
    let status: AttendanceStatus
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(status.rawValue)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(isSelected ? status.color : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(8)
        }
    }
}

struct AttendanceList: View {
    let gigId: String
    let bandId: String
    @State private var attendances: [Attendance] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Who's Coming")
                .font(.headline)
            
            ForEach(attendances, id: \.userId) { attendance in
                HStack {
                    Text(attendance.userId)
                    Spacer()
                    Text(attendance.status.rawValue)
                        .foregroundColor(attendance.status.color)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
        .onAppear {
            listenToAttendance()
        }
    }
    
    struct GigHeroView: View {
        let title: String
        let date: String
        
        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                
                VStack(spacing: 12) {
                    Text(title)
                        .font(.title.bold())
                        .foregroundColor(.white)
                    Text(date)
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding()
            }
            .frame(height: 200)
            .shadow(radius: 5)
        }
    }

    struct AttendanceToggle: View {
        @Binding var status: AttendanceStatus
        
        var body: some View {
            HStack {
                ForEach(AttendanceStatus.allCases, id: \.self) { status in
                    AttendanceButton(status: status, isSelected: self.status == status) {
                        self.status = status
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .shadow(radius: 2)
        }
    }

    private func listenToAttendance() {
        AttendanceService.shared.listenToAttendance(gigId: gigId) { attendances in
            self.attendances = attendances
        }
    }
}
