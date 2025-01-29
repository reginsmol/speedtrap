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

    @Timestamp(key: "createdAt", on: .create, format: .default)
    var createdAt: Date?

    @Timestamp(key: "updatedAt", on: .update, format: .default)
    var updatedAt: Date?

    @OptionalField(key: "vehicle")
    var vehicle: VehicleDetail?

    init() {}

    init(id: UUID? = nil, speed: Int8) {
        self.vehicle = VehicleDetail()
        self.id = id
        self.$speed.value = speed
    }

    func toDTO() -> CaptureDTO {
        .init(
            id: self.id,
            speed: self.speed,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt,
            fileId: self.fileId,
            licensePlate: self.vehicle?.licensePlate ?? nil
        )
    }
}
