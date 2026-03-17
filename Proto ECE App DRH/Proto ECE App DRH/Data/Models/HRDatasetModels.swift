import Foundation

struct CompanyDirectoryDataset: Decodable {
    let companies: [CompanyRecord]
}

struct CompanyRecord: Decodable, Identifiable {
    let id: String
    let name: String
    let siret: String
    let effectif: Int
    let address: PostalAddress
    let users: [CompanyUserRecord]
    let documents: [DocumentLink]
}

struct PostalAddress: Decodable {
    let line1: String
    let postalCode: String
    let city: String

    var compactLabel: String {
        "\(postalCode) \(city)"
    }
}

struct CompanyUserRecord: Decodable, Identifiable {
    let id: String
    let firstName: String
    let lastName: String
    let role: String
    let email: String
    let phone: String
    let isPrimaryContact: Bool

    var fullName: String {
        "\(firstName) \(lastName)"
    }
}

struct DocumentLink: Decodable, Identifiable {
    private let storedID: String?
    let title: String
    let type: String?
    let url: String

    var id: String {
        storedID ?? "\(title)-\(url)"
    }

    enum CodingKeys: String, CodingKey {
        case storedID = "id"
        case title
        case type
        case url
    }
}

struct ContractDataset: Decodable {
    let contracts: [ContractRecord]
}

struct ContractRecord: Decodable, Identifiable {
    let id: String
    let companyId: String
    let companyName: String
    let code: String
    let name: String
    let contractType: String
    let status: String
    let mandatory: Bool
    let startDate: String
    let renewalDate: String
    let coveredEmployees: Int
    let monthlyContribution: Double
    let documentLinks: [DocumentLink]
}

struct EmployeeDataset: Decodable {
    let employees: [EmployeeRecord]
}

struct EmployeeRecord: Decodable, Identifiable {
    let id: String
    let companyId: String
    let companyName: String
    let firstName: String
    let lastName: String
    let birthDate: String
    let status: String
    let familySituation: String
    let numberOfChildren: Int
    let annualGrossSalary: Double
    let annualPresenceRate: Double
    let employmentStartDate: String
    let affiliationStartDate: String
    let workEmail: String
    let address: PostalAddress

    var fullName: String {
        "\(firstName) \(lastName)"
    }
}

struct EmployeeContractDataset: Decodable {
    let employeeContracts: [EmployeeContractRecord]
}

struct EmployeeContractRecord: Decodable, Identifiable {
    let id: String
    let employeeId: String
    let companyId: String
    let companyName: String
    let familySituation: String
    let numberOfChildren: Int
    let beneficiaryCount: Int
    let coveredRisks: CoveredRisks
    let contractIds: [String]
    let contractStatus: String
}

struct CoveredRisks: Decodable {
    let health: Bool
    let supplementary: Bool
    let disability: Bool
}

struct ContractLifecycleDataset: Decodable {
    let events: [ContractLifecycleEventRecord]
}

struct ContractLifecycleEventRecord: Decodable, Identifiable {
    let id: String
    let companyId: String
    let employeeId: String?
    let contractId: String?
    let date: String
    let eventType: String
    let status: String
    let severity: String
    let title: String
    let description: String
}

struct HRRepositorySnapshot {
    let companies: [CompanyRecord]
    let contracts: [ContractRecord]
    let employees: [EmployeeRecord]
    let employeeContracts: [EmployeeContractRecord]
    let events: [ContractLifecycleEventRecord]
}
