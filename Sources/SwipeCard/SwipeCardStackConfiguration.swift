//
//  SwipeCardStackConfiguration.swift
//  SwipeCard
//
//  Created by unko on 2025/4/29.
//

import Foundation
import SwiftUI

/// 卡片堆叠视图的配置结构体
/// 用于定义卡片之间的层叠关系、视觉效果和动画效果
/// 支持自定义堆叠间距、缩放比例及入场动画
public struct SwipeCardStackConfiguration: Sendable {
    // MARK: — 卡片层叠样式
    /// 每一层比上一层额外缩小的比例（默认 0.03）
    /// 这个值决定了堆叠卡片之间的大小差异，值越大，下方卡片看起来越小
    public var stackScaleFactor: CGFloat
    
    /// 每一层比上一层额外向下偏移的距离（默认 12 点）
    /// 这个值决定了堆叠卡片之间的垂直间距，值越大，卡片堆叠时露出的部分越多
    public var stackYOffset: CGFloat

    // MARK: — 入场动画
    /// 卡片入场动画配置结构体
    /// 定义了卡片进入视图时的动画效果
    public struct EntryAnimation: Sendable {
        /// 入场动画曲线（默认为弹簧动画）
        /// 控制卡片出现时的动画方式
        public var curve: Animation
        
        /// 层级间的延迟（秒）（默认 0.1 秒）
        /// 堆叠卡片间动画启动的时间差，创造级联动画效果
        public var delay: Double
        
        /// 初始状态的缩放（默认 0.9）
        /// 卡片动画开始前的初始缩放比例
        public var initialScale: CGFloat
        
        /// 初始状态的 Y 偏移（默认 20 点）
        /// 卡片动画开始前的初始垂直位置偏移量
        public var initialOffsetY: CGFloat

        /// 初始化入场动画配置
        /// - Parameters:
        ///   - curve: 动画曲线，默认为响应时间 0.5 秒、阻尼比 0.6 的弹簧动画
        ///   - delay: 层级间动画延迟，默认 0.1 秒
        ///   - initialScale: 初始缩放比例，默认 0.9
        ///   - initialOffsetY: 初始 Y 轴偏移，默认 20 点
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

    /// 入场动画配置实例
    public var entryAnimation: EntryAnimation

    /// 初始化卡片堆叠配置
    /// - Parameters:
    ///   - stackScaleFactor: 堆叠层级间的缩放因子，默认 0.03
    ///   - stackYOffset: 堆叠层级间的 Y 轴偏移，默认 12 点
    ///   - entryAnimation: 入场动画配置，默认使用 EntryAnimation 的默认配置
    public init(
        stackScaleFactor: CGFloat = 0.03,
        stackYOffset: CGFloat = 12,
        entryAnimation: EntryAnimation = .init()
    ) {
        self.stackScaleFactor = stackScaleFactor
        self.stackYOffset = stackYOffset
        self.entryAnimation = entryAnimation
    }

    /// 默认的卡片堆叠配置实例
    public static let `default` = SwipeCardStackConfiguration()
}
