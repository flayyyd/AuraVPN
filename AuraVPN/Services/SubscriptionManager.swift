import Foundation
import SwiftUI

public enum SmartLinkType {
    case subscription(url: String)
    case server(node: ServerNode)
    case unsupported
}

@MainActor
public class SubscriptionManager: ObservableObject {
    public static let shared = SubscriptionManager()
    
    @Published public var subscriptions: [SubscriptionModel] = []
    @Published public var customServers: [ServerNode] = []
    @Published public var isUpdating: Bool = false
    @Published public var lastErrorMessage: String?
    
    private let storageKey = "AuraVPN_Subscriptions_v1"
    private let customServersKey = "AuraVPN_CustomServers_v1"
    
    public init() {
        loadFromStorage()
        if subscriptions.isEmpty {
            loadDemoSubscription()
        }
    }
    
    // MARK: - Умное определение содержимого ссылки из буфера обмена
    public func analyzeLink(_ rawText: String) -> SmartLinkType {
        let trimmed = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 1. Проверка на ссылку подписки (HTTP / HTTPS)
        if trimmed.lowercased().hasPrefix("http://") || trimmed.lowercased().hasPrefix("https://") {
            return .subscription(url: trimmed)
        }
        
        // 2. Проверка на одиночный сервер протокола VLESS, VMess, Trojan, SS, Hysteria 2
        if let node = parseProxyUri(trimmed) {
            return .server(node: node)
        }
        
        return .unsupported
    }
    
    // MARK: - Парсинг одиночного узла прокси
    public func parseProxyUri(_ uri: String) -> ServerNode? {
        let trimmed = uri.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: trimmed), let scheme = url.scheme?.lowercased() else { return nil }
        
        let protocolType: ProxyProtocol
        switch scheme {
        case "vless": protocolType = .vless
        case "vmess": protocolType = .vmess
        case "trojan": protocolType = .trojan
        case "ss": protocolType = .shadowsocks
        case "hysteria2", "hy2": protocolType = .hysteria2
        case "tuic": protocolType = .tuic
        case "wireguard", "wg": protocolType = .wireguard
        default: return nil
        }
        
        // Название сервера из хэша #Название
        var nodeName = "Новый сервер"
        if let fragment = url.fragment, let decoded = fragment.removingPercentEncoding {
            nodeName = decoded.replacingOccurrences(of: "+", with: " ")
        }
        
        let country = detectCountry(from: nodeName)
        let ping = Int.random(in: 15...55)
        
        return ServerNode(
            id: UUID().uuidString,
            name: nodeName,
            countryCode: country.code,
            flag: country.code,
            subtitle: "\(protocolType.rawValue) • \(country.label)",
            detailDesc: "Пользовательский сервер \(protocolType.rawValue)",
            type: .custom,
            pingMs: ping,
            isRecommended: false,
            badgeText: protocolType.rawValue,
            proxyProtocol: protocolType,
            rawUri: trimmed
        )
    }
    
    // MARK: - Добавление / Загрузка подписки по URL (как в HAPP)
    public func addSubscription(url: String, customName: String? = nil) async throws {
        guard let requestUrl = URL(string: url.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            throw URLError(.badURL)
        }
        
        isUpdating = true
        defer { isUpdating = false }
        
        var request = URLRequest(url: requestUrl)
        request.timeoutInterval = 15
        request.setValue("Happ/3.2.0 (iPhone; iOS 17.5)", forHTTPHeaderField: "User-Agent")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.cannotParseResponse)
        }
        
        // 1. Парсинг заголовка Subscription-Userinfo: upload=...; download=...; total=...; expire=...
        var upload: Int64 = 0
        var download: Int64 = 0
        var total: Int64 = 0
        var expireDate: Date? = nil
        var profileTitle = customName
        
        if let userInfoHeader = httpResponse.value(forHTTPHeaderField: "Subscription-Userinfo") {
            let parts = userInfoHeader.components(separatedBy: ";")
            for part in parts {
                let kv = part.trimmingCharacters(in: .whitespaces).components(separatedBy: "=")
                if kv.count == 2 {
                    let key = kv[0].lowercased()
                    let val = kv[1]
                    if key == "upload", let num = Int64(val) { upload = num }
                    if key == "download", let num = Int64(val) { download = num }
                    if key == "total", let num = Int64(val) { total = num }
                    if key == "expire", let ts = TimeInterval(val) {
                        expireDate = Date(timeIntervalSince1970: ts)
                    }
                }
            }
        }
        
        // 2. Имя профиля из заголовков Profile-Title
        if profileTitle == nil || profileTitle?.isEmpty == true {
            if let titleHeader = httpResponse.value(forHTTPHeaderField: "profile-title") {
                profileTitle = titleHeader.removingPercentEncoding ?? titleHeader
            } else if let host = requestUrl.host {
                profileTitle = host
            } else {
                profileTitle = "Подписка HAPP"
            }
        }
        
        // 3. Декодирование тела ответа (base64 или сырой текст с vless://, vmess://)
        var bodyString = String(data: data, encoding: .utf8) ?? ""
        if let base64DecodedData = Data(base64Encoded: bodyString.trimmingCharacters(in: .whitespacesAndNewlines)),
           let decoded = String(data: base64DecodedData, encoding: .utf8) {
            bodyString = decoded
        }
        
        var parsedServers: [ServerNode] = []
        var systemMessage: String? = nil
        let subId = UUID()
        
        let lines = bodyString.components(separatedBy: .newlines)
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }
            
            // Проверка на системное сообщение (часто провайдеры передают инфо-ноды с 📢 или Info)
            if trimmed.contains("📢") || trimmed.lowercased().contains("info") || trimmed.contains("новости") {
                if let hashIdx = trimmed.firstIndex(of: "#") {
                    let msg = String(trimmed[trimmed.index(after: hashIdx)...]).removingPercentEncoding ?? ""
                    systemMessage = msg.replacingOccurrences(of: "+", with: " ")
                    continue
                }
            }
            
            if var node = parseProxyUri(trimmed) {
                node.subscriptionId = subId
                parsedServers.append(node)
            }
        }
        
        let finalModel = SubscriptionModel(
            id: subId,
            name: profileTitle ?? "Подписка",
            url: url,
            uploadBytes: upload,
            downloadBytes: download,
            totalBytes: total,
            expireDate: expireDate,
            systemMessage: systemMessage,
            lastUpdated: Date(),
            servers: parsedServers
        )
        
        // Сохраняем или обновляем
        if let idx = subscriptions.firstIndex(where: { $0.url == url }) {
            subscriptions[idx] = finalModel
        } else {
            subscriptions.insert(finalModel, at: 0)
        }
        
        saveToStorage()
    }
    
    // MARK: - Обновить все подписки одновременно
    public func refreshAll() async {
        isUpdating = true
        defer { isUpdating = false }
        
        for sub in subscriptions {
            do {
                try await addSubscription(url: sub.url, customName: sub.name)
            } catch {
                print("Ошибка обновления подписки \(sub.name): \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Удаление подписки
    public func deleteSubscription(at indexSet: IndexSet) {
        subscriptions.remove(atOffsets: indexSet)
        saveToStorage()
    }
    
    public func deleteSubscription(id: UUID) {
        subscriptions.removeAll { $0.id == id }
        saveToStorage()
    }
    
    // MARK: - Добавление одиночного сервера
    public func addCustomServer(_ server: ServerNode) {
        customServers.insert(server, at: 0)
        saveToStorage()
    }
    
    // Определение страны по названию ноды
    private func detectCountry(from text: String) -> (code: String, label: String) {
        let lower = text.lowercased()
        if lower.contains("герман") || lower.contains("frankfurt") || lower.contains("de") || lower.contains("germany") {
            return ("DE", "Франкфурт")
        } else if lower.contains("росс") || lower.contains("моск") || lower.contains("ru") || lower.contains("russia") {
            return ("RU", "Москва")
        } else if lower.contains("нидерланд") || lower.contains("амстердам") || lower.contains("nl") || lower.contains("netherlands") {
            return ("NL", "Амстердам")
        } else if lower.contains("финлянд") || lower.contains("хельсинк") || lower.contains("fi") || lower.contains("finland") {
            return ("FI", "Хельсинки")
        } else if lower.contains("сша") || lower.contains("us") || lower.contains("usa") {
            return ("US", "Нью-Йорк")
        } else {
            return ("AUTO", "Быстрый сервер")
        }
    }
    
    // MARK: - Сохранение в UserDefaults
    private func saveToStorage() {
        if let encoded = try? JSONEncoder().encode(subscriptions) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
        if let encoded = try? JSONEncoder().encode(customServers) {
            UserDefaults.standard.set(encoded, forKey: customServersKey)
        }
    }
    
    private func loadFromStorage() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([SubscriptionModel].self, from: data) {
            self.subscriptions = decoded
        }
        if let data = UserDefaults.standard.data(forKey: customServersKey),
           let decoded = try? JSONDecoder().decode([ServerNode].self, from: data) {
            self.customServers = decoded
        }
    }
    
    // Предустановленная активная демо-подписка с полными атрибутами HAPP
    private func loadDemoSubscription() {
        let expire = Calendar.current.date(byAdding: .day, value: 48, to: Date())
        let demo = SubscriptionModel(
            id: UUID(),
            name: "HAPP Ultra Reality",
            url: "https://happ-proxy.cloud/sub/aura-user-928",
            uploadBytes: 4_294_967_296,     // 4.0 GB
            downloadBytes: 24_696_061_952,  // 23.0 GB -> ~27.0 GB использовано
            totalBytes: 107_374_182_400,    // 100 GB лимит
            expireDate: expire,
            systemMessage: "📢 Добавлены резервные VLESS Reality серверы в Германии и Финляндии. YouTube и Discord без замедления.",
            lastUpdated: Date(),
            servers: [
                ServerNode(
                    id: "happ_de_reality",
                    name: "🇩🇪 Frankfurt Reality-1",
                    countryCode: "DE",
                    flag: "DE",
                    subtitle: "VLESS Reality • 42 ms",
                    detailDesc: "Анти-DPI туннель без замедления",
                    type: .custom,
                    pingMs: 42,
                    isRecommended: true,
                    badgeText: "VLESS",
                    proxyProtocol: .vless
                ),
                ServerNode(
                    id: "happ_nl_vision",
                    name: "🇳🇱 Amsterdam Vision-2",
                    countryCode: "NL",
                    flag: "NL",
                    subtitle: "VLESS XTLS-Vision • 38 ms",
                    detailDesc: "Низкий пинг для игр и стримов",
                    type: .custom,
                    pingMs: 38,
                    isRecommended: false,
                    badgeText: "VLESS",
                    proxyProtocol: .vless
                )
            ]
        )
        self.subscriptions = [demo]
        saveToStorage()
    }
}
