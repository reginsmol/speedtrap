import Fluent
import Vapor

struct IndexContext: Encodable {
    var captures: [CaptureDTO]
}

struct CaptureContext: Encodable {
    var capture: CaptureDTO
}

func routes(_ app: Application) throws {
    app.get { req async throws -> View in
        let captures =
            try await Capture
            .query(on: req.db)
            .sort("createdAt", .descending)
            .limit(100)
            .all()
            .map { $0.toDTO() }

        return try await req.view.render(
            "index", IndexContext(captures: captures))
    }

    app.get("capture", ":id") { req async throws -> View in
        guard
            let capture =
                try await Capture
                .find(req.parameters.get("id"), on: req.db)
        else {
            return try await req.view.render("404")
        }

        return try await req.view.render(
            "capture", CaptureContext(capture: capture.toDTO()))
    }

    // try app.register(collection: TodoController())
    try app.register(collection: CaptureController())
}
