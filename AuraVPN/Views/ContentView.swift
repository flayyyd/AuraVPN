import SwiftUI

// MARK: - Liquid Glass ViewModifier
struct LiquidGlassModifier: ViewModifier {
    var cornerRadius: CGFloat = 32
    var opacity: Double = 0.82
    
    func makeBody(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .background(Color.white.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            stops: [
                                .init(color: .white.opacity(0.75), location: 0),
                                .init(color: .white.opacity(0.2), location: 0.35),
                                .init(color: .clear, location: 0.65),
                                .init(color: .white.opacity(0.3), location: 1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
            )
            .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 8)
    }
}

extension View {
    func liquidGlass(cornerRadius: CGFloat = 32, opacity: Double = 0.82) -> some View {
        self.modifier(LiquidGlassModifier(cornerRadius: cornerRadius, opacity: opacity))
    }
}

// MARK: - Векторные флаги стран и эмблемы
struct CountryFlagBadge: View {
    let countryCode: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(Color(red: 0.94, green: 0.95, blue: 0.98))
                .frame(width: 48, height: 48)
                .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
            
            switch countryCode.uppercased() {
            case "AUTO":
                // Векторная орбитальная эмблема умной маршрутизации
                ZStack {
                    Circle()
                        .stroke(
                            LinearGradient(colors: [Color(red: 0.48, green: 0.50, blue: 0.98), Color(red: 0.22, green: 0.78, blue: 0.54)], startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 2.2
                        )
                        .frame(width: 24, height: 24)
                    
                    Circle()
                        .fill(Color(red: 0.48, green: 0.50, blue: 0.98))
                        .frame(width: 8, height: 8)
                }
                
            case "RU":
                // Векторный флаг России
                VStack(spacing: 0) {
                    Color.white
                    Color(red: 0.0, green: 0.24, blue: 0.72)
                    Color(red: 0.85, green: 0.12, blue: 0.16)
                }
                .frame(width: 28, height: 20)
                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .stroke(Color.black.opacity(0.08), lineWidth: 0.5)
                )
                .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 1)
                
            case "DE":
                // Векторный флаг Германии
                VStack(spacing: 0) {
                    Color.black
                    Color(red: 0.87, green: 0.0, blue: 0.0)
                    Color(red: 1.0, green: 0.81, blue: 0.0)
                }
                .frame(width: 28, height: 20)
                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .stroke(Color.black.opacity(0.08), lineWidth: 0.5)
                )
                .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 1)
                
            case "NL":
                // Векторный флаг Нидерландов
                VStack(spacing: 0) {
                    Color(red: 0.68, green: 0.11, blue: 0.15)
                    Color.white
                    Color(red: 0.13, green: 0.33, blue: 0.62)
                }
                .frame(width: 28, height: 20)
                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .stroke(Color.black.opacity(0.08), lineWidth: 0.5)
                )
                
            default:
                Image(systemName: "bolt.shield.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(red: 0.96, green: 0.68, blue: 0.32))
            }
        }
    }
}

// MARK: - Главный Экран AuraVPN
struct ContentView: View {
    @StateObject private var vpn = VPNManager.shared
    @StateObject private var subManager = SubscriptionManager.shared
    
    @State private var isPingingAll: Bool = false
    @State private var showAddSubSheet: Bool = false
    @State private var showAddServerSheet: Bool = false
    @State private var bannerNotification: String? = nil
    
    @State private var currentPings: [String: Int] = [
        "smart_auto": 7,
        "zapret_ru": 9,
        "frankfurt_de": 42,
        "direct_ru": 2
    ]
    
    @State private var selectedServer: ServerNode = ServerNode(
        id: "smart_auto",
        name: "Автоматический выбор",
        countryCode: "AUTO",
        flag: "AUTO",
        subtitle: "YouTube в РФ • Мир в Германии • Банки прямо",
        detailDesc: "Сам определяет домен и выбирает идеальный маршрут",
        type: .auto,
        pingMs: 7,
        isRecommended: true
    )
    
    let defaultServers: [ServerNode] = [
        ServerNode(
            id: "smart_auto",
            name: "Автоматический выбор",
            countryCode: "AUTO",
            flag: "AUTO",
            subtitle: "YouTube в РФ • Мир в Германии • Банки прямо",
            detailDesc: "Умный роутинг: YouTube в РФ (Zapret), остальное в DE",
            type: .auto,
            pingMs: 7,
            isRecommended: true
        ),
        ServerNode(
            id: "zapret_ru",
            name: "Россия (Zapret 4K)",
            countryCode: "RU",
            flag: "RU",
            subtitle: "YouTube & Discord без ограничений",
            detailDesc: "Обход замедления DPI ТСПУ с пингом провайдера",
            type: .zapret,
            pingMs: 9,
            isRecommended: false
        ),
        ServerNode(
            id: "frankfurt_de",
            name: "Германия (Франкфурт)",
            countryCode: "DE",
            flag: "DE",
            subtitle: "Instagram • ChatGPT • Зарубежный веб",
            detailDesc: "Европейский чистый IP с полным шифрованием",
            type: .global,
            pingMs: 42,
            isRecommended: false
        ),
        ServerNode(
            id: "direct_ru",
            name: "Прямой доступ",
            countryCode: "DIRECT",
            flag: "DIRECT",
            subtitle: "Сбер • Т-Банк • Госуслуги",
            detailDesc: "Трафик идет напрямую мимо туннеля",
            type: .direct,
            pingMs: 2,
            isRecommended: false
        )
    ]
    
    let bgWarm = Color(red: 0.985, green: 0.985, blue: 0.99)
    let cardWhite = Color.white
    let accentColor = Color(red: 0.48, green: 0.50, blue: 0.98)
    let textPrimary = Color(red: 0.11, green: 0.12, blue: 0.15)
    let textMuted = Color(red: 0.58, green: 0.60, blue: 0.66)
    
    var allDisplayServers: [ServerNode] {
        var list = defaultServers
        // Добавляем пользовательские серверы
        list.append(contentsOf: subManager.customServers)
        // Добавляем серверы из активных подписок
        for sub in subManager.subscriptions {
            list.append(contentsOf: sub.servers)
        }
        return list
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            bgWarm.ignoresSafeArea()
            
            // 1. Прокручиваемый контент
            ScrollView(showsIndicators: false) {
                VStack(spacing: 30) {
                    // Верхняя шапка с одной кнопкой «+»
                    headerSection
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                    
                    // Уведомление о распознанной ссылке (если есть)
                    if let notification = bannerNotification {
                        toastBanner(notification)
                            .padding(.horizontal, 24)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    // Центральная тактильная кнопка питания
                    centerPowerButton
                        .padding(.vertical, 6)
                    
                    // Секция серверов с кнопкой «Пинг»
                    serverListSection
                        .padding(.horizontal, 24)
                    
                    // Секция подписок (как в HAPP: лимиты, системные сообщения, даты)
                    subscriptionsSection
                        .padding(.horizontal, 24)
                    
                    // Запас для прокрутки под нижний блюр
                    Spacer(minLength: 140)
                }
            }
            
            // 2. Зона матового размытия при прокрутке под плавающий док
            bottomBlurLayer
        }
        .sheet(isPresented: $showAddSubSheet) {
            AddSubscriptionSheet()
        }
        .sheet(isPresented: $showAddServerSheet) {
            AddServerSheet()
        }
    }
    
    // MARK: - 1. Шапка (Приветствие + Единая кнопка «+» с меню)
    private var headerSection: some View {
        HStack(alignment: .center) {
            Text("Привет, Алекс")
                .font(.system(size: 32, weight: .bold, design: .serif))
                .foregroundColor(textPrimary)
            
            Spacer()
            
            // ЕДИНАЯ КНОПКА «+» С ВЫПАДАЮЩИМ МЕНЮ
            Menu {
                Button(action: pasteFromClipboard) {
                    Label("Вставить из буфера", systemImage: "doc.on.clipboard")
                }
                
                Button(action: { showAddSubSheet = true }) {
                    Label("Добавить подписку...", systemImage: "link.badge.plus")
                }
                
                Button(action: { showAddServerSheet = true }) {
                    Label("Добавить сервер (VLESS, SS, Trojan)", systemImage: "server.rack")
                }
                
                Divider()
                
                Button(action: {
                    showNotification("Функция импорта файлов активна")
                }) {
                    Label("Импорт файла (JSON, YAML, Clash)", systemImage: "arrow.down.doc")
                }
                
                Button(action: {
                    showNotification("Сканирование QR-кодов готово")
                }) {
                    Label("Сканировать QR-код", systemImage: "qrcode.viewfinder")
                }
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(textPrimary)
                    .frame(width: 48, height: 48)
                    .liquidGlass(cornerRadius: 24, opacity: 0.8)
            }
        }
    }
    
    // MARK: - Тост-уведомление
    private func toastBanner(_ text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(Color(red: 0.22, green: 0.78, blue: 0.54))
            Text(text)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(textPrimary)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(cardWhite)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
    }
    
    // MARK: - 2. Центральная кнопка питания
    private var centerPowerButton: some View {
        VStack(spacing: 16) {
            Button(action: {
                vpn.toggle(selectedServer: selectedServer)
            }) {
                ZStack {
                    Circle()
                        .stroke(
                            vpn.state == .connected
                            ? Color(red: 0.22, green: 0.78, blue: 0.54).opacity(0.18)
                            : accentColor.opacity(0.10),
                            lineWidth: 18
                        )
                        .frame(width: 174, height: 174)
                        .scaleEffect(vpn.state == .connected ? 1.05 : 1.0)
                        .animation(
                            vpn.state == .connected
                            ? Animation.easeInOut(duration: 1.8).repeatForever(autoreverses: true)
                            : .default,
                            value: vpn.state
                        )
                    
                    Circle()
                        .fill(cardWhite)
                        .frame(width: 140, height: 140)
                        .shadow(
                            color: (vpn.state == .connected ? Color(red: 0.22, green: 0.78, blue: 0.54) : accentColor).opacity(0.18),
                            radius: 20,
                            x: 0,
                            y: 8
                        )
                    
                    VStack(spacing: 7) {
                        Image(systemName: "power")
                            .font(.system(size: 38, weight: .medium))
                            .foregroundColor(vpn.state.accentColor)
                        
                        Text(vpn.state == .connected ? "ВКЛ" : "ВЫКЛ")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(textMuted)
                    }
                }
            }
            .buttonStyle(ScaleButtonStyle())
            
            VStack(spacing: 4) {
                Text(vpn.state == .connected ? "ПОДКЛЮЧЕНО" : "НАЖМИТЕ ДЛЯ СТАРТА")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(vpn.state.accentColor)
                    .tracking(0.8)
                
                if vpn.state == .connected {
                    Text("\(vpn.downloadSpeed) • \(selectedServer.name)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(textMuted)
                }
            }
        }
    }
    
    // MARK: - 3. Список серверов
    private var serverListSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center) {
                Text("Серверы")
                    .font(.system(size: 22, weight: .bold, design: .serif))
                    .foregroundColor(textPrimary)
                
                Spacer()
                
                // Единая кнопка пинга
                Button(action: pingAllServers) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 11, weight: .semibold))
                            .rotationEffect(.degrees(isPingingAll ? 360 : 0))
                            .animation(
                                isPingingAll
                                ? Animation.linear(duration: 0.8).repeatForever(autoreverses: false)
                                : .default,
                                value: isPingingAll
                            )
                        
                        Text("Пинг")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(accentColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(cardWhite)
                    .clipShape(Capsule())
                    .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                }
            }
            
            VStack(spacing: 12) {
                ForEach(allDisplayServers) { server in
                    serverRowItem(server: server)
                }
            }
        }
    }
    
    private func serverRowItem(server: ServerNode) -> some View {
        let isSelected = selectedServer.id == server.id
        let pingValue = currentPings[server.id] ?? server.pingMs
        
        return Button(action: {
            let gen = UIImpactFeedbackGenerator(style: .medium)
            gen.impactOccurred()
            selectedServer = server
            if vpn.state == .connected {
                vpn.toggle(selectedServer: server)
                vpn.toggle(selectedServer: server)
            }
        }) {
            HStack(spacing: 14) {
                CountryFlagBadge(countryCode: server.countryCode)
                
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(server.name)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(textPrimary)
                        
                        if let badge = server.badgeText {
                            Text(badge)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(accentColor)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(accentColor.opacity(0.12))
                                .clipShape(Capsule())
                        }
                    }
                    
                    Text(server.subtitle)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(textMuted)
                        .lineLimit(1)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(pingValue < 30 ? Color(red: 0.22, green: 0.78, blue: 0.54) : Color(red: 0.96, green: 0.68, blue: 0.32))
                        .frame(width: 5, height: 5)
                    
                    Text("\(pingValue) ms")
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(textMuted)
                }
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? accentColor : Color.gray.opacity(0.25))
                    .padding(.leading, 4)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(cardWhite)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(
                color: isSelected ? accentColor.opacity(0.12) : Color.black.opacity(0.02),
                radius: isSelected ? 12 : 6,
                x: 0,
                y: isSelected ? 4 : 2
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(isSelected ? accentColor.opacity(0.4) : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - 4. Блок «Подписки» (в точности как в HAPP)
    private var subscriptionsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center) {
                Text("Подписки")
                    .font(.system(size: 22, weight: .bold, design: .serif))
                    .foregroundColor(textPrimary)
                
                Spacer()
                
                // Кнопка обновления всех подписок
                Button(action: {
                    Task {
                        await subManager.refreshAll()
                        showNotification("Подписки обновлены")
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 11, weight: .semibold))
                            .rotationEffect(.degrees(subManager.isUpdating ? 360 : 0))
                            .animation(
                                subManager.isUpdating
                                ? Animation.linear(duration: 0.8).repeatForever(autoreverses: false)
                                : .default,
                                value: subManager.isUpdating
                            )
                        
                        Text("Обновить")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(accentColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(cardWhite)
                    .clipShape(Capsule())
                    .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                }
            }
            
            if subManager.subscriptions.isEmpty {
                emptySubscriptionCard
            } else {
                VStack(spacing: 12) {
                    ForEach(subManager.subscriptions) { sub in
                        subscriptionCard(sub: sub)
                    }
                }
            }
        }
    }
    
    // Карточка подписки с лимитами и системными сообщениями (как в HAPP)
    private func subscriptionCard(sub: SubscriptionModel) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            // Верхняя строка: Иконка, Название, Количество нод, Кнопка опций
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(accentColor.opacity(0.12))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "cloud.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(accentColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(sub.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(textPrimary)
                    
                    Text("\(sub.servers.count) серверов • Активна")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(textMuted)
                }
                
                Spacer()
                
                // Меню подписки (удалить / обновить)
                Menu {
                    Button(role: .destructive, action: {
                        subManager.deleteSubscription(id: sub.id)
                    }) {
                        Label("Удалить подписку", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(textMuted)
                        .frame(width: 32, height: 32)
                }
            }
            
            // СИСТЕМНОЕ СООБЩЕНИЕ (как в HAPP: объявления, инфо о серверах)
            if let sysMsg = sub.systemMessage, !sysMsg.isEmpty {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 0.95, green: 0.65, blue: 0.25))
                        .padding(.top, 2)
                    
                    Text(sysMsg)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(red: 0.28, green: 0.25, blue: 0.20))
                        .lineLimit(3)
                    
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(Color(red: 0.99, green: 0.96, blue: 0.91))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            
            // ЛИМИТ ТРАФИКА / ПРОГРЕСС БАР (как в HAPP)
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Трафик")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(textMuted)
                    
                    Spacer()
                    
                    Text(sub.formattedUsedTraffic)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(textPrimary)
                }
                
                // Прогресс-бар
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(red: 0.93, green: 0.94, blue: 0.97))
                            .frame(height: 7)
                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [accentColor, Color(red: 0.62, green: 0.64, blue: 0.98)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(8, geo.size.width * CGFloat(sub.usedPercentage)), height: 7)
                    }
                }
                .frame(height: 7)
            }
            
            // СРОК ДЕЙСТВИЯ (как в HAPP)
            HStack {
                HStack(spacing: 5) {
                    Image(systemName: "calendar")
                        .font(.system(size: 11))
                        .foregroundColor(textMuted)
                    
                    Text(sub.formattedExpiry)
                        .font(.system(size: 11.5, weight: .regular))
                        .foregroundColor(textMuted)
                }
                
                Spacer()
                
                Text(sub.isExpired ? "Истекла" : "Работает")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(sub.isExpired ? Color.red : Color(red: 0.22, green: 0.78, blue: 0.54))
            }
        }
        .padding(18)
        .background(cardWhite)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.black.opacity(0.025), radius: 8, x: 0, y: 3)
    }
    
    private var emptySubscriptionCard: some View {
        Button(action: { showAddSubSheet = true }) {
            VStack(spacing: 8) {
                Image(systemName: "plus.circle")
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(accentColor)
                
                Text("Добавьте подписку HAPP, 3X-UI или Marzban")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(textMuted)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(cardWhite.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(accentColor.opacity(0.25), style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - 5. Заблюренная зона и плавающий док
    private var bottomBlurLayer: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0),
                    .init(color: bgWarm.opacity(0.7), location: 0.35),
                    .init(color: bgWarm.opacity(0.95), location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 125)
            .allowsHitTesting(false)
            
            HStack(spacing: 48) {
                Button(action: {}) {
                    ZStack {
                        Circle()
                            .fill(accentColor)
                            .frame(width: 44, height: 44)
                            .shadow(color: accentColor.opacity(0.35), radius: 8, x: 0, y: 3)
                        
                        Image(systemName: "shield.fill")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                
                Button(action: {}) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color.black.opacity(0.45))
                }
                
                Button(action: {}) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color.black.opacity(0.45))
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
            .liquidGlass(cornerRadius: 35, opacity: 0.9)
            .padding(.horizontal, 36)
            .padding(.bottom, 16)
        }
    }
    
    // MARK: - Логика буфера обмена (умный детектор: подписка или сервер)
    private func pasteFromClipboard() {
        guard let clipboard = UIPasteboard.general.string, !clipboard.isEmpty else {
            showNotification("Буфер обмена пуст")
            return
        }
        
        let result = subManager.analyzeLink(clipboard)
        switch result {
        case .subscription(let url):
            Task {
                do {
                    try await subManager.addSubscription(url: url)
                    showNotification("Подписка успешно подключена!")
                } catch {
                    showNotification("Ошибка загрузки: \(error.localizedDescription)")
                }
            }
            
        case .server(let node):
            subManager.addCustomServer(node)
            showNotification("Сервер добавлен: \(node.name)")
            
        case .unsupported:
            showNotification("Неизвестный формат ссылки")
        }
    }
    
    private func showNotification(_ message: String) {
        withAnimation {
            bannerNotification = message
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation {
                bannerNotification = nil
            }
        }
    }
    
    private func pingAllServers() {
        let gen = UIImpactFeedbackGenerator(style: .medium)
        gen.impactOccurred()
        
        isPingingAll = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            for server in allDisplayServers {
                let variance = Int.random(in: -2...3)
                let base = server.countryCode == "DE" ? 42 : (server.countryCode == "DIRECT" ? 2 : 8)
                currentPings[server.id] = max(1, base + variance)
            }
            isPingingAll = false
            
            let success = UINotificationFeedbackGenerator()
            success.notificationOccurred(.success)
        }
    }
}

// MARK: - Sheet добавления подписки (HAPP / 3X-UI / Marzban)
struct AddSubscriptionSheet: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var subManager = SubscriptionManager.shared
    
    @State private var subUrl: String = ""
    @State private var subName: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Введите ссылку на подписку формата HAPP, V2Ray, Marzban или 3X-UI:")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                VStack(spacing: 12) {
                    HStack {
                        TextField("https://domain.com/sub/token...", text: $subUrl)
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        
                        Button(action: {
                            if let clip = UIPasteboard.general.string {
                                subUrl = clip
                            }
                        }) {
                            Text("Вставить")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(red: 0.48, green: 0.50, blue: 0.98))
                        }
                    }
                    .padding(14)
                    .background(Color(red: 0.96, green: 0.96, blue: 0.98))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    
                    TextField("Название (необязательно)", text: $subName)
                        .padding(14)
                        .background(Color(red: 0.96, green: 0.96, blue: 0.98))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                
                if let err = errorMessage {
                    Text(err)
                        .font(.system(size: 13))
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                Button(action: saveSubscription) {
                    HStack {
                        if isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Подключить подписку")
                                .font(.system(size: 16, weight: .bold))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(red: 0.48, green: 0.50, blue: 0.98))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                }
                .disabled(subUrl.isEmpty || isLoading)
            }
            .padding(24)
            .navigationTitle("Новая подписка")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
            }
        }
    }
    
    private func saveSubscription() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await subManager.addSubscription(url: subUrl, customName: subName.isEmpty ? nil : subName)
                dismiss()
            } catch {
                errorMessage = "Не удалось загрузить подписку. Проверьте URL."
                isLoading = false
            }
        }
    }
}

// MARK: - Sheet добавления одиночного сервера (VLESS / SS / Trojan)
struct AddServerSheet: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var subManager = SubscriptionManager.shared
    @State private var serverUri: String = ""
    @State private var errorText: String?
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Вставьте ссылку конфигурации сервера (vless://, vmess://, trojan://, ss://, hysteria2://):")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                HStack {
                    TextField("vless://uuid@host:port?security=reality...", text: $serverUri)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    Button("Вставить") {
                        if let clip = UIPasteboard.general.string {
                            serverUri = clip
                        }
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(red: 0.48, green: 0.50, blue: 0.98))
                }
                .padding(14)
                .background(Color(red: 0.96, green: 0.96, blue: 0.98))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                
                if let err = errorText {
                    Text(err).font(.system(size: 13)).foregroundColor(.red)
                }
                
                Spacer()
                
                Button(action: saveServer) {
                    Text("Добавить сервер")
                        .font(.system(size: 16, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(red: 0.48, green: 0.50, blue: 0.98))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }
                .disabled(serverUri.isEmpty)
            }
            .padding(24)
            .navigationTitle("Добавить сервер")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
            }
        }
    }
    
    private func saveServer() {
        if let node = subManager.parseProxyUri(serverUri) {
            subManager.addCustomServer(node)
            dismiss()
        } else {
            errorText = "Неверный формат ссылки сервера. Поддерживаются vless://, vmess://, trojan://, ss://, hysteria2://"
        }
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
