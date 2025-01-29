import Vapor

struct AuthMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        guard let key = request.headers.bearerAuthorization else {
            throw Abort(.unauthorized)
        }
        
        let result = try await request.jwt.verify(key.token, as: TestPayload.self)
        
        if !result.isAdmin {
            throw Abort(.unauthorized)
        }
        
        return try await next.respond(to: request)
    }
}
