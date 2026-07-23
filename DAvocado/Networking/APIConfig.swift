import Foundation

enum APIConfig {
    /// The real `davocado-backend` (Spring Boot) service has no `/v1` path prefix — routes are
    /// mounted directly at `/auth`, `/users`, `/scans` (see the repo's README/controllers).
    /// Mutable so verification/testing can point at a local mock server too.
    static var baseURL = URL(string: "https://davocado-backend-950009771312.us-central1.run.app")!
}
