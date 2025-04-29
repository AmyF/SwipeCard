//
//  SwipeConfiguration.swift
//  SwipeCard
//
//  Created by unko on 2025/4/27.
//

import SwiftUI

/// 滑动方向枚举
/// 定义卡片可滑动的四个基本方向
public enum SwipeDirection: Sendable {
    /// 向左滑动
    case left
    /// 向右滑动
    case right
    /// 向上滑动
    case up
    /// 向下滑动
    case down

    /// 判断当前方向是否为水平方向（左或右）
    /// - Returns: 如果是左右方向则返回 true，否则返回 false
    public var isHorizontal: Bool {
        self == .left || self == .right
    }

    /// 判断当前方向是否为垂直方向（上或下）
    /// - Returns: 如果是上下方向则返回 true，否则返回 false
    public var isVertical: Bool {
        self == .up || self == .down
    }
}

/// 滑动支持方向的选项集
/// 使用位掩码实现的选项集，用于配置支持的滑动方向组合
public struct SwipeSupportDirection: Sendable, OptionSet {
    /// 原始值，用于位掩码存储
    public let rawValue: Int

    /// 初始化方法
    /// - Parameter rawValue: 原始整数值
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// 水平方向滑动选项（左右）
    public static let horizontal = SwipeSupportDirection(rawValue: 1 << 0)
    /// 垂直方向滑动选项（上下）
    public static let vertical = SwipeSupportDirection(rawValue: 1 << 1)

    /// 支持所有方向的滑动选项
    public static let all: SwipeSupportDirection = [.horizontal, vertical]
}

/// 滑动配置结构体
/// 定义卡片滑动的各种行为参数和动画效果
public struct SwipeConfiguration: Sendable {
    /// 触觉反馈样式枚举
    /// 定义滑动时的触觉反馈方式
    public enum HapticStyle: Sendable {
        /// 禁用触觉反馈
        case disabled
        /// 基础触觉反馈（成功）
        case basic
        /// 增强触觉反馈，支持自定义反馈类型
        case enhanced(SensoryFeedback)

        /// 获取触觉反馈类型
        /// 根据当前设置返回适当的触觉反馈类型
        var feedbackType: SensoryFeedback {
            switch self {
            case .enhanced(let type):
                return type
            default:
                return .success
            }
        }
    }

    /// 动画配置结构体
    /// 定义卡片滑动过程中的各种动画效果
    public struct AnimationConfig: Sendable {
        /// 动画曲线类型枚举
        /// 定义不同的动画曲线风格
        public enum CurveType: Sendable {
            /// 弹簧动画
            /// - Parameters:
            ///   - damping: 阻尼比例
            ///   - response: 响应时间
            case spring(damping: CGFloat, response: CGFloat)
            /// 缓入缓出动画
            /// - Parameter duration: 动画持续时间
            case easeInOut(duration: CGFloat)
            /// 自定义动画
            /// - Parameter Animation: 自定义的动画对象
            case custom(Animation)

            /// 获取实际的动画对象
            /// 根据当前类型生成对应的 SwiftUI 动画
            var value: Animation {
                switch self {
                case .spring(let damping, let response):
                    return .spring(response: response, dampingFraction: damping)
                case .easeInOut(let duration):
                    return .easeInOut(duration: duration)
                case .custom(let animation):
                    return animation
                }
            }
        }

        /// 退出动画（滑动结束时）
        public var exit: Animation
        /// 交互式动画（滑动过程中）
        public var interactive: Animation
        /// 入场动画延迟时间
        public var entryDelay: Double

        /// 初始化动画配置
        /// - Parameters:
        ///   - exit: 退出动画曲线，默认为持续时间 0.4 秒的缓入缓出
        ///   - interactive: 交互式动画曲线，默认为响应式弹簧动画
        ///   - entryDelay: 入场动画延迟时间，默认 0.1 秒
        public init(
            exit: CurveType = .easeInOut(duration: 0.4),
            interactive: CurveType = .custom(.interactiveSpring(response: 0.3)),
            entryDelay: Double = 0.1
        ) {
            self.exit = exit.value
            self.interactive = interactive.value
            self.entryDelay = entryDelay
        }
    }

    /// 滑动判定阈值
    /// 卡片需要滑动超过该距离才会触发完整的滑出动作
    public let threshold: CGFloat
    /// 动画配置
    public let animationConfig: AnimationConfig
    /// 触觉反馈样式
    public let hapticStyle: HapticStyle
    /// 支持的滑动方向
    public let supportDirection: SwipeSupportDirection

    /// 初始化滑动配置
    /// - Parameters:
    ///   - threshold: 滑动判定阈值，默认 120 点
    ///   - animationConfig: 动画配置，默认使用 AnimationConfig 的默认配置
    ///   - hapticStyle: 触觉反馈样式，默认为基础反馈
    ///   - supportDirection: 支持的滑动方向，默认仅支持水平方向
    public init(
        threshold: CGFloat = 120,
        animationConfig: AnimationConfig = AnimationConfig(),
        hapticStyle: HapticStyle = .basic,
        supportDirection: SwipeSupportDirection = .horizontal,
    ) {
        self.threshold = threshold
        self.animationConfig = animationConfig
        self.hapticStyle = hapticStyle
        self.supportDirection = supportDirection
    }

    /// 默认的滑动配置实例
    public static let `default` = SwipeConfiguration()
}
