import SwiftUI
import AVFoundation

struct OnboardingLoopingVideo: View {
    @StateObject private var playback: LoopPlayback
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(url: URL) {
        _playback = StateObject(wrappedValue: LoopPlayback(url: url))
    }

    var body: some View {
        VideoSurface(player: playback.player)
            .onAppear { updatePlayback() }
            .onDisappear { playback.player.pause() }
            .onChange(of: scenePhase) { _, _ in updatePlayback() }
            .onChange(of: reduceMotion) { _, _ in updatePlayback() }
    }

    private func updatePlayback() {
        if scenePhase == .active && !reduceMotion {
            playback.player.play()
        } else {
            playback.player.pause()
        }
    }
}

private final class LoopPlayback: ObservableObject {
    let player: AVQueuePlayer
    private let looper: AVPlayerLooper

    init(url: URL) {
        let player = AVQueuePlayer()
        player.isMuted = true
        player.preventsDisplaySleepDuringVideoPlayback = false
        self.player = player
        looper = AVPlayerLooper(player: player, templateItem: AVPlayerItem(url: url))
    }
}

private struct VideoSurface: UIViewRepresentable {
    let player: AVPlayer

    func makeUIView(context: Context) -> Surface {
        let view = Surface()
        view.playerLayer.videoGravity = .resizeAspect
        view.playerLayer.player = player
        return view
    }

    func updateUIView(_ view: Surface, context: Context) { view.playerLayer.player = player }

    static func dismantleUIView(_ view: Surface, coordinator: ()) {
        view.playerLayer.player = nil
    }

    final class Surface: UIView {
        override class var layerClass: AnyClass { AVPlayerLayer.self }
        var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    }
}
