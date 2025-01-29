import Fluent
import Vapor

struct CaptureDTO: Content, Encodable {
    var id: UUID?
    var speed: Int8
    var createdAt: Date?
    var updatedAt: Date?
    var fileId: UUID

    var licensePlate: String?

    var imageUrl: String?

    func toModel() -> Capture {
        let model = Capture()

        model.id = self.id
        model.speed = self.speed
        model.createdAt = self.createdAt
        model.updatedAt = self.updatedAt
        model.fileId = self.fileId

        return model
    }
}
