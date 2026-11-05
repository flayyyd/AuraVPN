import Foundation
import NetworkExtension
import UIKit

@MainActor
public class VPNManager: ObservableObject {
    public static let shared = VPNManager()
    
    @Published public var state: VPNState = .disconnected
    @Published public var uploadSpeed: String = "0 KB/s"
    @Published public var downloadSpeed: String = "0 KB/s"
    @Published public var durationSeconds: Int = 0
    
    private var timer: Timer?
    private var providerManager: NETunnelProviderManager?
    
    public init() {
        loadProviderManager()
    }
    
    private func loadProviderManager() {
        NETunnelProviderManager.loadAllFromPreferences { [weak self] managers, error in
            Task { @MainActor in
                if let manager = managers?.first {
                    self?.providerManager = manager
                } else {
                    let newManager = NETunnelProviderManager()
                    newManager.localizedDescription = "AuraVPN Hybrid"
                    let proto = NETunnelProviderProtocol()
                    proto.providerBundleIdentifier = "com.auravpn.tunnel"
                    proto.serverAddress = "Aura Hybrid Gateway"
                    newManager.protocolConfiguration = proto
                    newManager.isEnabled = true
                    self?.providerManager = newManager
                }
            }
        }
    }
    
    public func toggle(selectedServer: ServerNode) {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        
        switch state {
        case .disconnected:
            startVPN(server: selectedServer)
        case .connected, .connecting:
            stopVPN()
        case .disconnecting:
            break
        }
    }
    
    private func startVPN(server: ServerNode) {
        state = .connecting
        
        // Симуляция плавного рукопожатия туннеля
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            let notification = UINotificationFeedbackGenerator()
            notification.notificationOccurred(.success)
            self.state = .connected
            self.startStatsTimer()
        }
    }
    
    private func stopVPN() {
        state = .disconnecting
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            self.state = .disconnected
            self.stopStatsTimer()
        }
    }
    
    private func startStatsTimer() {
        durationSeconds = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                self.durationSeconds += 1
                let dl = Double.random(in: 15.0...48.5)
                let ul = Double.random(in: 2.1...8.4)
                self.downloadSpeed = String(format: "%.1f MB/s", dl)
                self.uploadSpeed = String(format: "%.1f MB/s", ul)
            }
        }
    }
    
    private func stopStatsTimer() {
        timer?.invalidate()
        timer = nil
        downloadSpeed = "0 KB/s"
        uploadSpeed = "0 KB/s"
        durationSeconds = 0
    }
}
