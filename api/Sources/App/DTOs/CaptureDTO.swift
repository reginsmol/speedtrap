import Fluent
import Vapor

struct CaptureDTO: Content, Encodable {
    var id: UUID?
    var speed: Int8
    var licensePlate: String?
    var createdAt: Date?
    var updatedAt: Date?
    var fileId: UUID

    var imageUrl: String?

    func toModel() -> Capture {
        let model = Capture()

        model.id = self.id
        model.speed = self.speed
        model.licensePlate = self.licensePlate
        model.createdAt = self.createdAt
        model.updatedAt = self.updatedAt
        model.fileId = self.fileId

        return model
    }
}
