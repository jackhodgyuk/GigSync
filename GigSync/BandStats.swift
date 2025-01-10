import Foundation

struct BandStats {
    let totalGigs: Int
    let totalRevenue: Double
    let activeMembers: Int
    let totalSongs: Int
    let revenueChart: [ChartData]
}

struct ChartData: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Double
}
