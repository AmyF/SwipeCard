//
//  SwipeCard.swift
//  SwipeCard
//
//  Created by unko on 2025/4/27.
//

import SwiftUI

/// 可滑动卡片组件
/// 实现了常见的卡片滑动交互效果，支持左、右、上、下四个方向的滑动
public struct SwipeCard<Content: View>: View {
    /// 卡片滑动配置
    private let configuration: SwipeConfiguration
    /// 卡片内容视图
    private let content: Content
    /// 手势处理器，处理卡片的滑动行为和状态
    @StateObject private var gestureHandler: SwipeGestureHandler
    /// 是否允许交互，防止动画过程中重复操作
    @State private var isInteractionEnabled = true

    /// 开始滑动时的回调，参数为滑动方向和进度
    private let onBegin: ((SwipeDirection, CGFloat) -> Void)?
    /// 取消滑动时的回调
    private let onCancel: (() -> Void)?
    /// 完成滑动判定的回调，返回值决定是否真正完成滑动
    private let onComplete: ((SwipeDirection) -> Bool)?
    /// 滑动完全结束后的回调
    private let onFinish: ((SwipeDirection) -> Void)?

    /// 初始化滑动卡片
    /// - Parameters:
    ///   - configuration: 卡片滑动配置
    ///   - onBegin: 开始滑动时的回调
    ///   - onCancel: 取消滑动时的回调
    ///   - onComplete: 完成滑动判定的回调
    ///   - onFinish: 滑动完全结束后的回调
    ///   - content: 卡片内容视图构造器
    init(
        configuration: SwipeConfiguration,
        onBegin: ((SwipeDirection, CGFloat) -> Void)? = nil,
        onCancel: (() -> Void)? = nil,
        onComplete: ((SwipeDirection) -> Bool)? = nil,
        onFinish: ((SwipeDirection) -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.configuration = configuration
        self.content = content()
        self.onBegin = onBegin
        self.onCancel = onCancel
        self.onComplete = onComplete
        self.onFinish = onFinish
        self._gestureHandler = StateObject(
            wrappedValue: SwipeGestureHandler(configuration: configuration)
        )
    }

    public var body: some View {
        content
            // 应用偏移效果，实现卡片移动
            .offset(gestureHandler.offset)
            // 滑动过程中的缩放效果
            .scaleEffect(gestureHandler.scaleEffect)
            // 滑动过程中的透明度效果
            .opacity(gestureHandler.opacity)
            // 滑动过程中的旋转效果
            .rotationEffect(
                .degrees(Double(gestureHandler.offset.width / 25)),
                anchor: gestureHandler.rotationAnchor
            )
            // 添加拖动手势
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        // 禁用状态时不处理手势
                        guard isInteractionEnabled else { return }
                        // 更新手势状态
                        gestureHandler.handleDrag(gesture)
                        // 触发开始滑动回调
                        onBegin?(
                            gestureHandler.activeDirection ?? .right,
                            gestureHandler.swipeProgress
                        )
                    }
                    .onEnded { _ in
                        // 禁用状态时不处理手势
                        guard isInteractionEnabled else { return }
                        // 处理滑动完成
                        handleSwipeCompletion()
                    }
            )
            // 滑动过程中的动画效果
            .animation(
                configuration.animationConfig.interactive, value: gestureHandler.offset
            )
            // 进度超过50%时的触觉反馈
            .sensoryFeedback(
                .selection, trigger: gestureHandler.swipeProgress >= 0.5
            ) { old, new in
                // 禁用触觉反馈时不触发
                if case .disabled = configuration.hapticStyle { return false }
                return new
            }
            // 进度达到100%时的触觉反馈
            .sensoryFeedback(
                configuration.hapticStyle.feedbackType, trigger: gestureHandler.swipeProgress >= 1.0
            ) { old, new in
                // 禁用触觉反馈时不触发
                if case .disabled = configuration.hapticStyle { return false }
                return new
            }
    }

    /// 处理滑动完成后的逻辑
    private func handleSwipeCompletion() {
        // 如果滑动进度达到阈值，执行滑动完成逻辑
        if gestureHandler.swipeProgress >= 1.0 {
            isInteractionEnabled = false
            let finalDirection = gestureHandler.activeDirection ?? .right
            // 通过回调确定是否真正完成滑动
            let shouldComplete = onComplete?(finalDirection) ?? true
            if shouldComplete {
                // 执行滑出动画
                withAnimation(configuration.animationConfig.exit) {
                    gestureHandler.offset = CGSize(
                        // 根据方向计算最终偏移量
                        width: gestureHandler.activeDirection?.isHorizontal ?? true
                            ? (gestureHandler.activeDirection == .right ? 1000 : -1000) : 0,
                        height: gestureHandler.activeDirection?.isVertical ?? true
                            ? (gestureHandler.activeDirection == .down ? 1000 : -1000) : 0
                    )
                } completion: {
                    // 动画完成后触发回调
                    onFinish?(finalDirection)
                }
            } else {
                // 如果不完成滑动，重置位置
                resetCardPosition()
            }
            isInteractionEnabled = true
        } else {
            // 滑动进度不足，重置位置并触发取消回调
            resetCardPosition()
            onCancel?()
        }
    }

    /// 重置卡片位置到初始状态
    private func resetCardPosition() {
        withAnimation(configuration.animationConfig.interactive) {
            gestureHandler.resetState()
        }
    }
}
