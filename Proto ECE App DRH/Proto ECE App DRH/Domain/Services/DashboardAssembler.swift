import Foundation
import SwiftUI

// MARK: - Dashboard State (computed from JSON data)

struct DashboardState {
    // Cotisations
    let totalMonthlyContribution: Double
    let previousMonthlyContribution: Double
    let nextDueDate: String

    // Arrêts de travail
    let totalArretDays: Int
    let arretTrend: Int
    let arretSinceDate: String
    let arretSegments: ArretSegments

    // Affiliations (percentages computed from employee_contracts)
    let healthAffiliationRate: Double
    let supplementaryAffiliationRate: Double
    let disabilityAffiliationRate: Double
    let totalEmployees: Int

    // Notification badge
    let pendingActionsCount: Int

    // Consommation bar chart
    let consommationValues: [Double]
}

struct ArretSegments {
    let maladieDays: Int
    let accidentDays: Int
    let otherDays: Int

    var total: Int { maladieDays + accidentDays + otherDays }

    var maladieAngle: Double {
        guard total > 0 else { return 0 }
        return Double(maladieDays) / Double(total) * 360.0
    }

    var accidentAngle: Double {
        guard total > 0 else { return 0 }
        return Double(accidentDays) / Double(total) * 360.0
    }

    var otherAngle: Double {
        guard total > 0 else { return 0 }
        return Double(otherDays) / Double(total) * 360.0
    }
}

// MARK: - Assembler

enum DashboardAssembler {

    static func assemble(
        snapshot: HRRepositorySnapshot,
        appData: AppDataRoot
    ) -> DashboardState {

        // --- Cotisations ---
        let totalMonthly = snapshot.contracts.reduce(0.0) { $0 + $1.monthlyContribution }
        // Simulate previous month slightly less
        let previousMonthly = totalMonthly * 0.98

        // Next due date: 15th of current month or next month
        let nextDue = computeNextDueDate()

        // --- Arrêts de travail ---
        let arretEvents = snapshot.events.filter { event in
            ["arret_maladie", "nouvel_at", "conge_famille"].contains(event.eventType)
                && event.status == "pending"
        }

        let segments = computeArretSegments(from: arretEvents)
        let totalDays = segments.total
        // Trend: compare with a baseline (closed events)
        let closedEvents = snapshot.events.filter { $0.eventType == "cloture_dossier" }
        let trend = max(0, arretEvents.count - closedEvents.count)

        // Since date: earliest pending arret event
        let sortedArrets = arretEvents.sorted { $0.date < $1.date }
        let sinceDate = sortedArrets.first.map { AppFormatters.date($0.date) } ?? ""

        // --- Affiliations ---
        let totalEmps = snapshot.employees.count
        let contracts = snapshot.employeeContracts
        let healthCount = contracts.filter { $0.coveredRisks.health }.count
        let supplementaryCount = contracts.filter { $0.coveredRisks.supplementary }.count
        let disabilityCount = contracts.filter { $0.coveredRisks.disability }.count

        let healthRate = totalEmps > 0 ? Double(healthCount) / Double(totalEmps) : 0
        let suppRate = totalEmps > 0 ? Double(supplementaryCount) / Double(totalEmps) : 0
        let disabRate = totalEmps > 0 ? Double(disabilityCount) / Double(totalEmps) : 0

        // --- Pending actions count ---
        let pendingCount = snapshot.events.filter { $0.status == "pending" }.count

        return DashboardState(
            totalMonthlyContribution: totalMonthly,
            previousMonthlyContribution: previousMonthly,
            nextDueDate: nextDue,
            totalArretDays: totalDays,
            arretTrend: trend,
            arretSinceDate: "Depuis le \(sinceDate)",
            arretSegments: segments,
            healthAffiliationRate: healthRate,
            supplementaryAffiliationRate: suppRate,
            disabilityAffiliationRate: disabRate,
            totalEmployees: totalEmps,
            pendingActionsCount: pendingCount,
            consommationValues: appData.consommationBarChart
        )
    }

    // MARK: - Helpers

    private static func computeNextDueDate() -> String {
        let calendar = Calendar.current
        let now = Date()
        let day = calendar.component(.day, from: now)
        var components = calendar.dateComponents([.year, .month], from: now)
        components.day = 15
        if day >= 15 {
            components.month = (components.month ?? 1) + 1
        }
        guard let date = calendar.date(from: components) else { return "" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "dd/MM/yy"
        return formatter.string(from: date)
    }

    private static func computeArretSegments(from events: [ContractLifecycleEventRecord]) -> ArretSegments {
        var maladie = 0
        var accident = 0
        var other = 0

        for event in events {
            let days = extractDays(from: event.description)
            switch event.eventType {
            case "arret_maladie":
                maladie += days
            case "nouvel_at":
                accident += days
            default:
                other += days
            }
        }

        return ArretSegments(maladieDays: maladie, accidentDays: accident, otherDays: other)
    }

    private static func extractDays(from description: String) -> Int {
        // Pattern: "XX jours"
        let pattern = #"(\d+)\s*jours"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: description, range: NSRange(description.startIndex..., in: description)),
              let range = Range(match.range(at: 1), in: description) else {
            return 0
        }
        return Int(description[range]) ?? 0
    }
}
