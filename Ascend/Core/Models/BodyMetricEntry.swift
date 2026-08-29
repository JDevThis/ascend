import Foundation
import SwiftData

@Model
final class BodyMetricEntry {
    var id: UUID
    var date: Date
    /// Stored in pounds regardless of display unit; converted for presentation.
    var weightLb: Double?
    var bodyFatPercentage: Double?
    var chestIn: Double?
    var waistIn: Double?
    var hipsIn: Double?
    var armsIn: Double?
    var legsIn: Double?
    var source: MetricSource

    init(
        date: Date = .now,
        weightLb: Double? = nil,
        bodyFatPercentage: Double? = nil,
        chestIn: Double? = nil,
        waistIn: Double? = nil,
        hipsIn: Double? = nil,
        armsIn: Double? = nil,
        legsIn: Double? = nil,
        source: MetricSource = .manual
    ) {
        self.id = UUID()
        self.date = date
        self.weightLb = weightLb
        self.bodyFatPercentage = bodyFatPercentage
        self.chestIn = chestIn
        self.waistIn = waistIn
        self.hipsIn = hipsIn
        self.armsIn = armsIn
        self.legsIn = legsIn
        self.source = source
    }
}

enum MetricSource: String, Codable {
    case manual = "Manual"
    case healthKit = "Health"
}

@Model
final class ProgressPhoto {
    var id: UUID
    var date: Date
    var angleRaw: String

    @Attribute(.externalStorage)
    var imageData: Data

    var angle: PhotoAngle {
        get { PhotoAngle(rawValue: angleRaw) ?? .front }
        set { angleRaw = newValue.rawValue }
    }

    init(date: Date = .now, angle: PhotoAngle, imageData: Data) {
        self.id = UUID()
        self.date = date
        self.angleRaw = angle.rawValue
        self.imageData = imageData
    }
}
