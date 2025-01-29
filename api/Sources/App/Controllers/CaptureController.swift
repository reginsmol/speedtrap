import Fluent
import Vapor

struct Greeting: Content, Encodable {
    var hello: String
}

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
        let capture: Capture = try req.content.decode(CaptureDTO.self).toModel()

        let token = Environment.get("ALPR_TOKEN")!

        let alprResponse = try await req.client.post(
            "https://api.platerecognizer.com/v1/plate-reader"
        ) { alprRequest in

            let imageUrl =
                "https://loadql.dev/cdn-cgi/imagedelivery/QcwQm0dWPprrgKR8Ke1MXw/\(capture.fileId)/public"
            // Encode JSON to the request body.

            try alprRequest.content.encode(["upload_url": imageUrl])

            // Add auth header to the request
            alprRequest.headers.add(name: "Authorization", value: "Token \(token)")
        }

        let vehicle: AlprResponseDTO = try alprResponse.content.decode(AlprResponseDTO.self)

        if vehicle.results.indices.contains(0) {
            capture.vehicle = VehicleDetail()
            capture.vehicle?.confidence = vehicle.results[0].score
            capture.vehicle?.region = vehicle.results[0].region.code
            capture.vehicle?.licensePlate = vehicle.results[0].plate
        }

        try await capture.save(on: req.db)

        return capture.toDTO()
    }
}
