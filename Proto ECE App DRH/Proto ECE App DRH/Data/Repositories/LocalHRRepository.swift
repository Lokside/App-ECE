import Foundation

protocol HRRepository {
    func fetchDashboardData() throws -> HRRepositorySnapshot
    func fetchAppData() throws -> AppDataRoot
}

struct LocalHRRepository: HRRepository {
    private let bundle: Bundle

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    func fetchDashboardData() throws -> HRRepositorySnapshot {
        let subdirectory = "Data/Datasets"

        let companies = try bundle
            .decode(CompanyDirectoryDataset.self, from: "companies_and_users", subdirectory: subdirectory)
            .companies

        let contracts = try bundle
            .decode(ContractDataset.self, from: "contracts", subdirectory: subdirectory)
            .contracts

        let employees = try bundle
            .decode(EmployeeDataset.self, from: "employees", subdirectory: subdirectory)
            .employees

        let employeeContracts = try bundle
            .decode(EmployeeContractDataset.self, from: "employee_contracts", subdirectory: subdirectory)
            .employeeContracts

        let events = try bundle
            .decode(ContractLifecycleDataset.self, from: "contract_lifecycle", subdirectory: subdirectory)
            .events

        return HRRepositorySnapshot(
            companies: companies,
            contracts: contracts,
            employees: employees,
            employeeContracts: employeeContracts,
            events: events
        )
    }

    func fetchAppData() throws -> AppDataRoot {
        try bundle.decode(AppDataRoot.self, from: "appData", subdirectory: "Data/Datasets")
    }
}
