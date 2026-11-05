import Foundation
import SwiftUI

// MARK: - Поддерживаемые протоколы прокси
public enum ProxyProtocol: String, Codable, CaseIterable {
    case vless = "VLESS"
    case vmess = "VMess"
    case trojan = "Trojan"
    case shadowsocks = "Shadowsocks"
    case hysteria2 = "Hysteria 2"
    case tuic = "TUIC v5"
    case wireguard = "WireGuard"
    case direct = "Direct"
    
    public var iconName: String {
        switch self {
        case .vless: return "bolt.shield.fill"
        case .vmess: return "network"
        case .trojan: return "lock.shield.fill"
        case .shadowsocks: return "paperplane.fill"
        case .hysteria2: return "flame.fill"
        case .tuic: return "waveform.path.ecg"
        case .wireguard: return "shield.lefthalf.filled"
        case .direct: return "arrow.triangle.branch"
        }
    }
}

public enum ServerType: String, Codable {
    case auto = "Умный Авто-выбор"
    case zapret = "Zapret Ultra (РФ)"
    case global = "Германия (Франкфурт)"
    case direct = "Прямой трафик (РФ)"
    case custom = "Пользовательский"
}

public struct ServerNode: Identifiable, Hashable, Codable {
    public let id: String
    public let name: String
    public let countryCode: String
    public let flag: String
    public let subtitle: String
    public let detailDesc: String
    public let type: ServerType
    public var pingMs: Int
    public let isRecommended: Bool
    public let badgeText: String?
    public var proxyProtocol: ProxyProtocol?
    public var rawUri: String?
    public var subscriptionId: UUID?
    
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
        badgeText: String? = nil,
        proxyProtocol: ProxyProtocol? = nil,
        rawUri: String? = nil,
        subscriptionId: UUID? = nil
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
        self.proxyProtocol = proxyProtocol
        self.rawUri = rawUri
        self.subscriptionId = subscriptionId
    }
}

// MARK: - Модель подписки (как в HAPP: лимиты, системные сообщения, даты)
public struct SubscriptionModel: Identifiable, Codable, Equatable {
    public let id: UUID
    public var name: String
    public var url: String
    public var uploadBytes: Int64
    public var downloadBytes: Int64
    public var totalBytes: Int64 // 0 = безлимит
    public var expireDate: Date?
    public var systemMessage: String? // Системные сообщения от провайдера подписки
    public var lastUpdated: Date
    public var servers: [ServerNode]
    
    public init(
        id: UUID = UUID(),
        name: String,
        url: String,
        uploadBytes: Int64 = 0,
        downloadBytes: Int64 = 0,
        totalBytes: Int64 = 0,
        expireDate: Date? = nil,
        systemMessage: String? = nil,
        lastUpdated: Date = Date(),
        servers: [ServerNode] = []
    ) {
        self.id = id
        self.name = name
        self.url = url
        self.uploadBytes = uploadBytes
        self.downloadBytes = downloadBytes
        self.totalBytes = totalBytes
        self.expireDate = expireDate
        self.systemMessage = systemMessage
        self.lastUpdated = lastUpdated
        self.servers = servers
    }
    
    // Суммарный использованный трафик в байтах
    public var usedBytes: Int64 {
        uploadBytes + downloadBytes
    }
    
    // Процент использованного трафика (0.0 - 1.0)
    public var usedPercentage: Double {
        guard totalBytes > 0 else { return 0.0 }
        let pct = Double(usedBytes) / Double(totalBytes)
        return min(max(pct, 0.0), 1.0)
    }
    
    // Форматированное отображение трафика (как в HAPP)
    public var formattedUsedTraffic: String {
        let used = formatBytes(usedBytes)
        if totalBytes > 0 {
            let total = formatBytes(totalBytes)
            return "\(used) из \(total)"
        } else {
            return "\(used) • Безлимит"
        }
    }
    
    // Форматированная дата окончания
    public var formattedExpiry: String {
        guard let expire = expireDate else { return "Бессрочно" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return "Истекает: " + formatter.string(from: expire)
    }
    
    public var isExpired: Bool {
        guard let expire = expireDate else { return false }
        return expire < Date()
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let gb = Double(bytes) / 1_073_741_824.0
        if gb >= 1.0 {
            return String(format: "%.1f ГБ", gb)
        }
        let mb = Double(bytes) / 1_048_576.0
        return String(format: "%.0f МБ", mb)
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
            return Color(red: 0.22, green: 0.76, blue: 0.52)
        case .connecting, .disconnecting:
            return Color(red: 0.98, green: 0.70, blue: 0.35)
        case .disconnected:
            return Color(red: 0.47, green: 0.49, blue: 0.96)
        }
    }
}
