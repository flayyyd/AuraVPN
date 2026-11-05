import Foundation
import SwiftUI

public enum ServerType: String, Codable {
    case auto = "Умный Авто-выбор"
    case zapret = "Zapret Ultra (РФ)"
    case global = "Германия (Франкфурт)"
    case direct = "Прямой трафик (РФ)"
}

public struct ServerNode: Identifiable, Hashable {
    public let id: String
    public let name: String
    public let countryCode: String
    public let flag: String
    public let subtitle: String
    public let detailDesc: String
    public let type: ServerType
    public let pingMs: Int
    public let isRecommended: Bool
    public let badgeText: String?
    
    public init(
        id: String,
        name: String,
        countryCode: String,
        flag: String,
        subtitle: String,
        detailDesc: String,
        type: ServerType,
        pingMs: Int,
        isRecommended: Bool = false,
        badgeText: String? = nil
    ) {
        self.id = id
        self.name = name
        self.countryCode = countryCode
        self.flag = flag
        self.subtitle = subtitle
        self.detailDesc = detailDesc
        self.type = type
        self.pingMs = pingMs
        self.isRecommended = isRecommended
        self.badgeText = badgeText
    }
}

public enum VPNState: String {
    case disconnected = "Отключено"
    case connecting = "Подключение..."
    case connected = "Защищено"
    case disconnecting = "Отключение..."
    
    public var accentColor: Color {
        switch self {
        case .connected:
            return Color(red: 0.22, green: 0.76, blue: 0.52) // Свежий изумрудный
        case .connecting, .disconnecting:
            return Color(red: 0.98, green: 0.70, blue: 0.35) // Теплый янтарный
        case .disconnected:
            return Color(red: 0.47, green: 0.49, blue: 0.96) // Фирменный лавандовый с Dribbble
        }
    }
}
