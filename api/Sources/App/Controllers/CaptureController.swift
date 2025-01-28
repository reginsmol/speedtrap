import Fluent
import Vapor

struct CreateCaptureResponse: Content {
    var capture: CaptureDTO
}

struct CaptureController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let captures = routes.grouped("api")

        captures.get("captures", use: self.index)
        captures.post("captures", use: self.create)
    }

    @Sendable
    func index(req: Request) async throws -> [CaptureDTO] {
        try await Capture.query(on: req.db)
            .sort("createdAt", .descending)
            .all()
            .map {
                $0.toDTO()
            }
    }

    @Sendable
    func create(req: Request) async throws -> CaptureDTO {
        let capture = try req.content.decode(CaptureDTO.self).toModel()

        try await capture.save(on: req.db)
        let token = Environment.get("ALPR_TOKEN")!

        let response = try await req.client.post("https://api.platerecognizer.com/v1/plate-reader")
        { req in

            let imageUrl =
                "https://loadql.dev/cdn-cgi/imagedelivery/QcwQm0dWPprrgKR8Ke1MXw/\(capture.fileId)/public"
            // Encode JSON to the request body.

            try req.content.encode(["upload_url": imageUrl])

            // Add auth header to the request
            req.headers.add(name: "Authorization", value: "Token \(token)")
        }

        print(response)

        return capture.toDTO()
    }
}
