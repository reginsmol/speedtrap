import Fluent
import FluentMongoDriver

import struct Foundation.Date
import struct Foundation.UUID

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.
final class Capture: Model, @unchecked Sendable {
    static let schema = "captures"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "fileId")
    var fileId: UUID

    @Field(key: "speed")
    var speed: Int8

    @Field(key: "licensePlate")
    var licensePlate: String?

    @Timestamp(key: "createdAt", on: .create, format: .iso8601)
    var createdAt: Date?

    @Timestamp(key: "updatedAt", on: .update, format: .iso8601)
    var updatedAt: Date?

    init() {}

    init(id: UUID? = nil, speed: Int8, licensePlate: String) {
        self.id = id
        self.$speed.value = speed
        self.$licensePlate.value = licensePlate
    }

    func toDTO() -> CaptureDTO {
        .init(
            id: self.id,
            speed: self.speed,
            licensePlate: self.licensePlate,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt,
            fileId: self.fileId
        )
    }
}
