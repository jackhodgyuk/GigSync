import Charts
import Foundation
import SwiftUI

struct BandStatsView: View {
    let band: Band
    @State private var stats: BandStats?
    @State private var selectedTimeframe: TimeFrame = .month
    
    var body: some View {
        List {
            Section("Performance") {
                StatsCardView(
                    title: "Total Gigs",
                    value: "\(stats?.totalGigs ?? 0)",
                    icon: "calendar"
                )
                
                StatsCardView(
                    title: "Revenue",
                    value: stats?.totalRevenue.formatted(.currency(code: "GBP")) ?? "£0",
                    icon: "dollarsign.circle"
                )
                
                if let chart = stats?.revenueChart {
                    Chart(chart) { item in
                        BarMark(
                            x: .value("Month", item.date),
                            y: .value("Amount", item.amount)
                        )
                    }
                    .frame(height: 200)
                }
            }
            
            Section("Band Activity") {
                StatsCardView(
                    title: "Active Members",
                    value: "\(stats?.activeMembers ?? 0)",
                    icon: "person.2"
                )
                
                StatsCardView(
                    title: "Songs in Setlists",
                    value: "\(stats?.totalSongs ?? 0)",
                    icon: "music.note.list"
                )
            }
        }
        .navigationTitle("Band Statistics")
        .onAppear {
            loadStats()
        }
    }
    
    private func loadStats() {
        Task {
            stats = try? await BandService.shared.getBandStats(
                bandId: band.id ?? "",
                timeframe: selectedTimeframe
            )
        }
    }
}
