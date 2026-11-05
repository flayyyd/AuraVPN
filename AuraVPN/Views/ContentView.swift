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
            .shadow(color: Color.black.opacity(0.10), radius: 22, x: 0, y: 10)
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
            
            switch countryCode {
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
                
            default:
                // Прямой доступ
                Image(systemName: "bolt.shield.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(red: 0.96, green: 0.68, blue: 0.32))
            }
        }
    }
}

// MARK: - Главный Экран
struct ContentView: View {
    @StateObject private var vpn = VPNManager.shared
    @State private var isPingingAll: Bool = false
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
    
    let servers: [ServerNode] = [
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
    
    var body: some View {
        ZStack(alignment: .bottom) {
            bgWarm.ignoresSafeArea()
            
            // 1. Прокручиваемый контент
            ScrollView(showsIndicators: false) {
                VStack(spacing: 34) {
                    // Верхнее приветствие (без лишних надписей)
                    headerSection
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                    
                    // Центральная кнопка питания
                    centerPowerButton
                        .padding(.vertical, 10)
                    
                    // Список серверов с общей кнопкой пинга справа
                    serverListSection
                        .padding(.horizontal, 24)
                    
                    // Запас для прокрутки под нижнюю заблюренную панель
                    Spacer(minLength: 140)
                }
            }
            
            // 2. Зона красивого размытия (Frosted Glass Blur) внизу экрана
            bottomBlurLayer
        }
    }
    
    // MARK: - 1. Верхнее приветствие (1 в 1 как в Dribbble макете: Имя + 2 стеклянные круглые кнопки)
    private var headerSection: some View {
        HStack(alignment: .center) {
            Text("Привет, Алекс")
                .font(.system(size: 32, weight: .bold, design: .serif))
                .foregroundColor(textPrimary)
            
            Spacer()
            
            HStack(spacing: 10) {
                // Кнопка быстрого поиска / пинга
                Button(action: pingAllServers) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(textPrimary)
                        .frame(width: 46, height: 46)
                        .liquidGlass(cornerRadius: 23, opacity: 0.7)
                }
                
                // Кнопка настроек
                Button(action: {
                    let gen = UIImpactFeedbackGenerator(style: .light)
                    gen.impactOccurred()
                }) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(textPrimary)
                        .frame(width: 46, height: 46)
                        .liquidGlass(cornerRadius: 23, opacity: 0.7)
                }
            }
        }
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
    
    // MARK: - 3. Список серверов (с одной кнопкой пинга справа)
    private var serverListSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center) {
                Text("Серверы")
                    .font(.system(size: 22, weight: .bold, design: .serif))
                    .foregroundColor(textPrimary)
                
                Spacer()
                
                // ЕДИНАЯ КНОПКА ПИНГА ДЛЯ ВСЕХ СЕРВЕРОВ
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
                ForEach(servers) { server in
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
                    Text(server.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(textPrimary)
                    
                    Text(server.subtitle)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(textMuted)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Аккуратный пинг без лишних кнопок
                HStack(spacing: 4) {
                    Circle()
                        .fill(pingValue < 30 ? Color(red: 0.22, green: 0.78, blue: 0.54) : Color(red: 0.96, green: 0.68, blue: 0.32))
                        .frame(width: 5, height: 5)
                    
                    Text("\(pingValue) ms")
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(textMuted)
                }
                
                // Радиокнопка выбора
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
    
    // MARK: - 4. Зона красивого блюра под нижней панелью
    private var bottomBlurLayer: some View {
        ZStack(alignment: .bottom) {
            // Градиентное размытие под контентом, уходящим вниз
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
            
            // Плавающий док Liquid Glass
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
    
    // Пинг сразу всех серверов
    private func pingAllServers() {
        let gen = UIImpactFeedbackGenerator(style: .medium)
        gen.impactOccurred()
        
        isPingingAll = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            for server in servers {
                let variance = Int.random(in: -2...3)
                let base = server.id == "frankfurt_de" ? 42 : (server.id == "direct_ru" ? 2 : 8)
                currentPings[server.id] = max(1, base + variance)
            }
            isPingingAll = false
            
            let success = UINotificationFeedbackGenerator()
            success.notificationOccurred(.success)
        }
    }
}
