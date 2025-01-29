import Fluent
import FluentMongoDriver
import JWT
import Leaf
import NIOSSL
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.http.server.configuration.address = .hostname("0.0.0.0", port: 8080)
    try app.databases.use(
        DatabaseConfigurationFactory.mongo(
            connectionString: Environment.get("DATABASE_URL")
                ?? "mongodb://localhost:27017/vapor_database"

        ), as: .mongo)

    app.migrations.add(CreateTodo())

    app.views.use(.leaf)

    app.asyncCommands.use(SignCommand(), as: "sign")

    let tokenSecret = HMACKey(from:Environment.get("JWT_TOKEN_SECRET")!)

    await app.jwt.keys.add(hmac: tokenSecret, digestAlgorithm: .sha256)

    // register routes
    try routes(app)
}
