import JWT
import Vapor

struct TestPayload: JWTPayload {
    // Maps the longer Swift property names to the
    // shortened keys used in the JWT payload.
    enum CodingKeys: String, CodingKey {
        case subject = "sub"
        case expiration = "exp"
        case isAdmin = "admin"
    }

    // The "sub" (subject) claim identifies the principal that is the
    // subject of the JWT.
    var subject: SubjectClaim

    // The "exp" (expiration time) claim identifies the expiration time on
    // or after which the JWT MUST NOT be accepted for processing.
    var expiration: ExpirationClaim

    // Custom data.
    // If true, the user is an admin.
    var isAdmin: Bool

    // Run any additional verification logic beyond
    // signature verification here.
    // Since we have an ExpirationClaim, we will
    // call its verify method.
    func verify(using algorithm: some JWTAlgorithm) async throws {
        try self.expiration.verifyNotExpired()
    }
}

struct SignCommand: AsyncCommand {
    struct Signature: CommandSignature {}

    var help: String {
        "Says hello"
    }

    func run(using context: CommandContext, signature: Signature) async throws {
        let payload = TestPayload(
            subject: "admin",
            expiration: .init(value: .distantFuture),
            isAdmin: true
        )

        let key: String = try await context.application.jwt.keys.sign(payload)
        print(key)
        
        print(try await context.application.jwt.keys.verify(key, as:TestPayload.self))
    }
}
