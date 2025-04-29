//
//  SwipeGestureHandler.swift
//  SwipeCard
//
//  Created by unko on 2025/4/27.
//

import SwiftUI

/// 滑动手势处理器
/// 负责处理卡片的滑动手势，计算滑动距离、方向和进度
/// 作为可观察对象提供给 SwipeCard 视图使用
@MainActor
final class SwipeGestureHandler: ObservableObject {
    /// 当前卡片的偏移量
    /// 随着手指拖动实时更新，控制卡片位置
    @Published var offset: CGSize = .zero

    /// 当前活跃的滑动方向
    /// 基于手势移动方向判断，用于确定卡片的视觉效果和动画
    @Published var activeDirection: SwipeDirection?

    /// 滑动完成度百分比 (0.0 - 1.0)
    /// 用于计算各种动画效果的强度，1.0 表示达到触发阈值
    @Published var swipeProgress: CGFloat = 0.0

    /// 卡片旋转锚点
    /// 基于滑动方向动态调整，使卡片旋转看起来更自然
    var rotationAnchor: UnitPoint {
        switch activeDirection {
        case .left: return .topLeading
        case .right: return .topTrailing
        default: return .center
        }
    }

    /// 卡片缩放效果
    /// 随着滑动进度增加轻微放大，增强视觉反馈
    var scaleEffect: CGFloat {
        1 + 0.02 * swipeProgress
    }

    /// 卡片透明度效果
    /// 随着滑动进度轻微减少不透明度
    var opacity: CGFloat {
        1 - 0.2 * swipeProgress
    }

    /// 滑动配置
    /// 提供阈值和支持方向等配置信息
    private let configuration: SwipeConfiguration

    /// 初始化滑动手势处理器
    /// - Parameter configuration: 滑动配置，决定卡片的滑动行为
    init(configuration: SwipeConfiguration) {
        self.configuration = configuration
    }

    /// 处理拖动手势
    /// 更新偏移量、计算进度和判断方向
    /// - Parameter gesture: 拖动手势的值
    func handleDrag(_ gesture: DragGesture.Value) {
        offset = gesture.translation
        swipeProgress = calculateProgress()
        activeDirection = calculateDirection()
    }

    /// 计算当前滑动进度
    /// 基于偏移量与阈值的比例，结果在 0 到 1 之间
    /// - Returns: 滑动完成度（0-1之间的值）
    private func calculateProgress() -> CGFloat {
        let horizontalProgress =
            configuration.supportDirection.contains(.horizontal) ? abs(offset.width) : 0
        let verticalProgress =
            configuration.supportDirection.contains(.vertical) ? abs(offset.height) : 0
        let maxOffset = max(horizontalProgress, verticalProgress)
        return min(maxOffset / configuration.threshold, 1.0)
    }

    /// 计算当前滑动方向
    /// 基于偏移量的方向和支持的滑动方向
    /// - Returns: 确定的滑动方向，或当进度不足时为 nil
    private func calculateDirection() -> SwipeDirection? {
        guard swipeProgress >= 0.3 else { return nil }

        let horizontalAllowed = configuration.supportDirection.contains(.horizontal)
        let verticalAllowed = configuration.supportDirection.contains(.vertical)

        if horizontalAllowed && !verticalAllowed {
            return offset.width > 0 ? .right : .left
        } else if verticalAllowed && !horizontalAllowed {
            return offset.height > 0 ? .down : .up
        }

        let isHorizontal = abs(offset.width) > abs(offset.height)

        if isHorizontal {
            return offset.width > 0 ? .right : .left
        } else {
            return offset.height > 0 ? .down : .up
        }
    }

    /// 重置手势状态
    /// 将所有属性恢复到初始值
    func resetState() {
        offset = .zero
        activeDirection = nil
        swipeProgress = 0.0
    }
}
