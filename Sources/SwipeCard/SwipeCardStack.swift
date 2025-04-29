//
//  SwipeCardStack.swift
//  SwipeCard
//
//  Created by unko on 2025/4/27.
//

import SwiftUI

/// SwipeCardStack 是一个堆叠式可滑动卡片组件
/// 管理多个可滑动卡片，实现类似 Tinder 的卡片堆叠滑动效果
/// 支持自定义卡片内容、滑动配置和堆叠效果
public struct SwipeCardStack<Data: Equatable, Content: View>: View where Data: Identifiable {
    /// 绑定的数据项数组，每一项对应一张卡片
    @Binding public var items: [Data]
    /// 单个卡片的滑动配置
    public var swipeConfiguration: SwipeConfiguration
    /// 卡片堆叠的配置，控制堆叠效果和动画
    public var stackConfiguration: SwipeCardStackConfiguration

    /// 卡片滑动判定回调，返回值决定是否完成滑动
    private var onSwipe: ((Data, SwipeDirection) -> Bool)?
    /// 滑动进行中的回调，提供滑动方向和进度信息
    private var onProgress: ((Data, SwipeDirection, _ progress: CGFloat) -> Void)?
    /// 滑动取消的回调
    private var onCancel: ((Data) -> Void)?
    /// 全部卡片滑完后的回调
    private var onFinished: ((Data, SwipeDirection) -> Void)?

    /// 卡片内容视图构造器
    @ViewBuilder public var content: (Data) -> Content

    /// 初始化卡片堆叠视图
    /// - Parameters:
    ///   - items: 数据项数组的绑定
    ///   - swipeConfiguration: 卡片滑动配置
    ///   - stackConfiguration: 卡片堆叠配置
    ///   - onSwipe: 滑动判定回调
    ///   - onProgress: 滑动进度回调
    ///   - onCancel: 滑动取消回调
    ///   - onFinished: 所有卡片滑完的回调
    ///   - content: 卡片内容视图构造器
    public init(
        items: Binding<[Data]>,
        swipeConfiguration: SwipeConfiguration = .default,
        stackConfiguration: SwipeCardStackConfiguration = .default,
        onSwipe: @escaping (Data, SwipeDirection) -> Bool,
        onProgress: @escaping (Data, SwipeDirection, _ progress: CGFloat) -> Void,
        onCancel: @escaping (Data) -> Void,
        onFinished: ((Data, SwipeDirection) -> Void)? = nil,
        @ViewBuilder content: @escaping (Data) -> Content
    ) {
        self._items = items
        self.swipeConfiguration = swipeConfiguration
        self.stackConfiguration = stackConfiguration
        self.onSwipe = onSwipe
        self.onProgress = onProgress
        self.onCancel = onCancel
        self.onFinished = onFinished
        self.content = content
    }

    /// 视图主体，创建卡片堆叠效果
    public var body: some View {
        ZStack {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                createSwipeCard(for: item, at: index, index: items.count - index - 1)
            }
            .animation(stackConfiguration.entryAnimation.curve, value: items)
        }
    }

    /// 创建单张滑动卡片
    /// - Parameters:
    ///   - item: 卡片对应的数据项
    ///   - position: 卡片在堆叠中的位置（0表示最顶层）
    ///   - index: 卡片的zIndex
    /// - Returns: 配置好的SwipeCard视图
    private func createSwipeCard(for item: Data, at position: Int, index: Int) -> some View {
        SwipeCard(configuration: swipeConfiguration) {
            onProgress?(item, $0, $1)
        } onCancel: {
            onCancel?(item)
        } onComplete: { direction in
            onSwipe?(item, direction) ?? false
        } onFinish: { direction in
            self.items.removeFirst()
            if items.isEmpty {
                onFinished?(item, direction)
            }
        } content: {
            content(item)
        }
        .scaleEffect(1 - CGFloat(position) * stackConfiguration.stackScaleFactor)
        .offset(y: CGFloat(position) * stackConfiguration.stackYOffset)
        .zIndex(Double(index))
        .entryAnimation(
            stackConfiguration.entryAnimation.curve
                .delay(stackConfiguration.entryAnimation.delay * Double(position)),
            initialScale: stackConfiguration.entryAnimation.initialScale,
            initialOffsetY: stackConfiguration.entryAnimation.initialOffsetY
        )
    }
}

/// 卡片入场动画效果的视图修饰器
struct EntryAnimation: ViewModifier {
    /// 动画曲线
    let curve: Animation
    /// 初始缩放比例
    let initialScale: CGFloat
    /// 初始Y轴偏移量
    let initialOffsetY: CGFloat

    /// 控制动画状态
    @State private var isVisible = false

    /// 应用入场动画效果
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .scaleEffect(isVisible ? 1 : initialScale)
            .offset(y: isVisible ? 0 : initialOffsetY)
            .onAppear {
                withAnimation(curve) {
                    isVisible = true
                }
            }
    }
}

/// View扩展，添加入场动画功能
extension View {
    /// 为视图添加入场动画
    /// - Parameters:
    ///   - curve: 动画曲线
    ///   - initialScale: 初始缩放比例
    ///   - initialOffsetY: 初始Y轴偏移量
    /// - Returns: 应用了入场动画的视图
    func entryAnimation(
        _ curve: Animation,
        initialScale: CGFloat,
        initialOffsetY: CGFloat
    ) -> some View {
        modifier(
            EntryAnimation(
                curve: curve,
                initialScale: initialScale,
                initialOffsetY: initialOffsetY
            ))
    }
}
