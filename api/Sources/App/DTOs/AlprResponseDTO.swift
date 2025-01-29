import Fluent
import Vapor

struct AlprResponseResultRegionDTO: Content {
    var code: String
    var score: Float
}

struct AlprResponseResultDTO: Content {
    var plate: String
    var score: Float
    var region: AlprResponseResultRegionDTO
}

struct AlprResponseDTO: Content {
    var processing_time: Float64
    var results: [AlprResponseResultDTO]
}
