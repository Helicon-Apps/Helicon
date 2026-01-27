//
//  File.swift
//  Helicon
//
//  Created by Yuriy Nefedov on 27.01.2026.
//

import SwiftUI
import AVFoundation
import Combine

public enum RepeatBehavior: Equatable {
    case afterDelay(TimeInterval)
    case onTap
}

/// SwiftUI video view that auto-plays on appear, scales to fit its container,
/// and never overflows its frame.
///
/// - Parameters:
///   - url: Video URL (local or remote).
///   - repeatBehavior: If non-nil, controls repeat behavior:
///                     `.afterDelay(TimeInterval)` restarts after delay,
///                     `.onTap` restarts on tap.
public struct AutoPlayer: View {
    public let url: URL
    public let repeatBehavior: RepeatBehavior?
    

    @StateObject private var controller = PlayerController()

    public init(url: URL, repeat repeatBehavior: RepeatBehavior? = nil) {
        self.url = url
        self.repeatBehavior = repeatBehavior
    }

    public var body: some View {
        PlayerContainerView(player: controller.player)
            .clipped()
            .contentShape(Rectangle())
            .onTapGesture {
                controller.handleTapRepeatIfNeeded()
            }
            .onAppear {
                controller.configure(url: url, repeatBehavior: repeatBehavior)
                controller.play()
            }
            .onDisappear {
                controller.stop()
            }
            .onChange(of: url) { _, newURL in
                controller.configure(url: newURL, repeatBehavior: repeatBehavior)
                controller.play()
            }
            .onChange(of: repeatBehavior) { _, newBehavior in
                controller.setRepeatBehavior(newBehavior)
            }
    }
}

// MARK: - UIKit-backed player view for precise layout/clipping

private struct PlayerContainerView: UIViewRepresentable {
    let player: AVPlayer

    func makeUIView(context: Context) -> PlayerUIView {
        let view = PlayerUIView()
        view.playerLayer.player = player
        view.playerLayer.videoGravity = .resizeAspect // scales to FIT container, no overflow
        view.clipsToBounds = true
        return view
    }

    func updateUIView(_ uiView: PlayerUIView, context: Context) {
        uiView.playerLayer.player = player
    }
}

private final class PlayerUIView: UIView {
    override class var layerClass: AnyClass { AVPlayerLayer.self }
    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
        clipsToBounds = true
        layer.masksToBounds = true
    }
}

// MARK: - Controller

@MainActor
private final class PlayerController: ObservableObject {
    let player = AVPlayer()

    private var endObserver: AnyCancellable?
    private var repeatBehavior: RepeatBehavior?
    private var currentItem: AVPlayerItem?

    func configure(url: URL, repeatBehavior: RepeatBehavior?) {
        self.repeatBehavior = repeatBehavior

        let item = AVPlayerItem(url: url)
        currentItem = item
        player.replaceCurrentItem(with: item)

        installEndObserver(for: item)
    }

    func setRepeatBehavior(_ repeatBehavior: RepeatBehavior?) {
        self.repeatBehavior = repeatBehavior
        if let item = currentItem {
            installEndObserver(for: item)
        }
    }

    func play() {
        player.play()
    }

    func stop() {
        player.pause()
        removeEndObserver()
        player.replaceCurrentItem(with: nil)
        currentItem = nil
    }

    private func installEndObserver(for item: AVPlayerItem) {
        removeEndObserver()

        guard repeatBehavior != nil else { return }

        endObserver = NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: item)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self else { return }
                switch self.repeatBehavior {
                case .afterDelay(let delay):
                    // Pause and remain at end. Only seek back to zero right before replay.
                    self.player.pause()
                    if delay <= 0 {
                        self.player.seek(to: .zero) { _ in
                            self.player.play()
                        }
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                            guard let self else { return }
                            self.player.seek(to: .zero) { _ in
                                self.player.play()
                            }
                        }
                    }
                case .onTap:
                    // Pause and remain at end; wait for user tap to seek and play.
                    self.player.pause()
                case .none:
                    break
                }
            }
    }

    func handleTapRepeatIfNeeded() {
        guard case .onTap? = repeatBehavior else { return }
        // If at end or paused, restart from beginning
        player.seek(to: .zero) { [weak self] _ in
            self?.player.play()
        }
    }

    private func removeEndObserver() {
        endObserver = nil
    }
}

//#Preview {
//    AutoPlayer(
//        url: .howItWorksVideoUrl,
//        repeat: .onTap
//    )
//}

