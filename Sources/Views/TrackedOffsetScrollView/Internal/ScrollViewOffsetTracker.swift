import SwiftUI

struct ScrollViewOffsetTracker: View {
    enum Namespace {
        static let id = "TrackedOffsetScrollView"
    }
    
    var body: some View {
        GeometryReader { proxy in
            Color.clear.preference(
                key: OffsetKey.self,
                value: value(for: proxy)
            )
        }
        .frame(height: .zero)
    }
    
    private func value(for proxy: GeometryProxy) -> CGPoint {
        proxy.frame(in: .named(Namespace.id)).origin
    }
    
    struct OffsetKey: PreferenceKey {
        static var defaultValue: CGPoint = .zero

        static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {}
    }
}
