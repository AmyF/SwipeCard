//
//  SwipeCardStackConfiguration.swift
//  G001UI
//
//  Created by unko on 2025/4/29.
//

import Foundation
import SwiftUI

public struct SwipeCardStackConfiguration: Sendable {
    // MARK: — 卡片层叠样式
    /// 每一层比上一层额外缩小的比例（默认 0.03）
    public var stackScaleFactor: CGFloat
    /// 每一层比上一层额外向下偏移的距离（默认 12）
    public var stackYOffset: CGFloat

    // MARK: — 入场动画
    public struct EntryAnimation: Sendable {
        /// 入场动画曲线（默认 Spring）
        public var curve: Animation
        /// 层级间的延迟（秒）（默认 0.1）
        public var delay: Double
        /// 初始状态的缩放（默认 0.9）
        public var initialScale: CGFloat
        /// 初始状态的 Y 偏移（默认 20）
        public var initialOffsetY: CGFloat

        public init(
            curve: Animation = .spring(response: 0.5, dampingFraction: 0.6),
            delay: Double = 0.1,
            initialScale: CGFloat = 0.9,
            initialOffsetY: CGFloat = 20
        ) {
            self.curve = curve
            self.delay = delay
            self.initialScale = initialScale
            self.initialOffsetY = initialOffsetY
        }
    }

    public var entryAnimation: EntryAnimation

    public init(
        stackScaleFactor: CGFloat = 0.03,
        stackYOffset: CGFloat = 12,
        entryAnimation: EntryAnimation = .init()
    ) {
        self.stackScaleFactor = stackScaleFactor
        self.stackYOffset = stackYOffset
        self.entryAnimation = entryAnimation
    }

    public static let `default` = SwipeCardStackConfiguration()
}
