import Fluent
import FluentMongoDriver

import struct Foundation.Date
import struct Foundation.UUID

final class VehicleDetail: @unchecked Sendable, Decodable, Encodable {
    // @Field(key: "licensePlate")
    var licensePlate: String?

    var region: String?
    // @Field(key: "confidence")
    var confidence: Float?

    init() {}

}
