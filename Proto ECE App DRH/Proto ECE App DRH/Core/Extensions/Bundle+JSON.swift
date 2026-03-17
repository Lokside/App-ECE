import Foundation

enum BundleJSONError: LocalizedError {
    case missingResource(String, String?)
    case unreadableResource(String, Error)
    case decodingFailed(String, Error)

    var errorDescription: String? {
        switch self {
        case .missingResource(let resource, let subdirectory):
            if let subdirectory {
                return "Missing resource \(resource).json in \(subdirectory)."
            }
            return "Missing resource \(resource).json."
        case .unreadableResource(let resource, let error):
            return "Unable to read \(resource).json: \(error.localizedDescription)"
        case .decodingFailed(let resource, let error):
            return "Unable to decode \(resource).json: \(error.localizedDescription)"
        }
    }
}

extension Bundle {
    func decode<T: Decodable>(
        _ type: T.Type,
        from resource: String,
        subdirectory: String? = nil
    ) throws -> T {
        let url =
            url(forResource: resource, withExtension: "json", subdirectory: subdirectory) ??
            url(forResource: resource, withExtension: "json")

        guard let url else {
            throw BundleJSONError.missingResource(resource, subdirectory)
        }

        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw BundleJSONError.unreadableResource(resource, error)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw BundleJSONError.decodingFailed(resource, error)
        }
    }
}
