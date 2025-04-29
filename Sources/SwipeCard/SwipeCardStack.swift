//
//  SwipeCardStack.swift
//  G001UI
//
//  Created by unko on 2025/4/27.
//

import SwiftUI

public struct SwipeCardStack<Data: Equatable, Content: View>: View where Data: Identifiable {
    @Binding public var items: [Data]
    public var swipeConfiguration: SwipeConfiguration
    public var stackConfiguration: SwipeCardStackConfiguration
    
    private var onSwipe: ((Data, SwipeDirection) -> Bool)?
    private var onProgress: ((Data, SwipeDirection, _ progress: CGFloat) -> Void)?
    private var onCancel: ((Data) -> Void)?
    private var onFinished: ((Data, SwipeDirection) -> Void)?
    
    @ViewBuilder public var content: (Data) -> Content
    
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
    
    public var body: some View {
        ZStack {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                createSwipeCard(for: item, at: items.count - index - 1, index: index)
            }
            .animation(stackConfiguration.entryAnimation.curve, value: items)
        }
        
    }
    
    private func createSwipeCard(for item: Data, at position: Int, index: Int) -> some View {
        SwipeCard(configuration: swipeConfiguration) {
            onProgress?(item, $0, $1)
        } onCancel: {
            onCancel?(item)
        } onComplete: { direction in
            onSwipe?(item, direction) ?? false
        } onFinish: { direction in
            self.items.removeLast()
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

struct EntryAnimation: ViewModifier {
    let curve: Animation
    let initialScale: CGFloat
    let initialOffsetY: CGFloat

    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .scaleEffect(isVisible ? 1 : initialScale)
            .offset(y:     isVisible ? 0 : initialOffsetY)
            .onAppear {
                withAnimation(curve) {
                    isVisible = true
                }
            }
    }
}

extension View {
    func entryAnimation(
        _ curve: Animation,
        initialScale: CGFloat,
        initialOffsetY: CGFloat
    ) -> some View {
        modifier(EntryAnimation(
            curve: curve,
            initialScale: initialScale,
            initialOffsetY: initialOffsetY
        ))
    }
}
