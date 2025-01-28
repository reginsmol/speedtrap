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
        return capture.toDTO()
    }
}
