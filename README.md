# SwipeCardStackKit

A highly customizable SwiftUI card swipe stack with interactive animations, haptic feedback and entry/exit transitions.

---

## 🔥 Features

- **Full Customization**: Configure swipe threshold, interactive animation, exit animation, stack scale/offset, and entry delay/initial state.
- **Interactive Animations**: Drag-linked scale, opacity, rotation; spring or custom `Animation`.
- **Haptic & Sound**: Built-in basic/enhanced haptics.
- **Clean API**: `SwipeConfiguration` for gesture & exit, `SwipeCardStackConfiguration` for stack visuals & entry.

---

## 📦 Installation

### Swift Package Manager

1. In Xcode, select **File → Swift Packages → Add Package Dependency…**  
2. Enter repository URL:  
```
https://github.com/AmyF/SwipeCard
```
3. Choose branch or version, finish.

---

## 🚀 Quick Start

```swift

import SwiftUI
import SwipeCard

struct ContentView: View {
    @State private var cards: [CardItem] = (0..<5).map { _ in CardItem(color: .random) }

    var body: some View {
        SwipeCardStack(
            items: $cards,
            swipeConfiguration: .default,
            stackConfiguration: .default,
            onSwipe: { item, direction in
                true
            },
            onProgress: { item, direction, progress in
                // drag progress (0…1)
            },
            onCancel: { item in
                // cancelled
            },
            onFinished: { item, direction in
                // all cards done
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    cards = (0..<5).map { _ in CardItem(color: .random) }
                }
            }
        ) { item in
            CardView(item: item)
        }
        .padding()
    }
}

struct CardItem: Identifiable, Equatable {
    let id = UUID()
    let color: Color
}

struct CardView: View {
    let item: CardItem
    
    var body: some View {
        Rectangle()
            .fill(item.color)
            .frame(width: 300, height: 400)
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .shadow(radius: 5)
            .overlay {
                Text(item.id.uuidString)
                    .foregroundStyle(.white)
                    .shadow(color: .black, radius: 5)
                    .padding()
            }
    }
}

extension Color {
    static var random: Color {
        Color(
            red: .random(in: 0.4...1),
            green: .random(in: 0.4...1),
            blue: .random(in: 0.4...1)
        )
    }
}


```