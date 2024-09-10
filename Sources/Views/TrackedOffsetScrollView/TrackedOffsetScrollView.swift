import SwiftUI

public struct TrackedOffsetScrollView<Content: View>: View {
    public typealias ScrollAction = (_ offset: CGPoint) -> Void
    
    private let axis: Axis.Set
    private let showsIndicators: Bool
    private let onScroll: ScrollAction
    private let content: () -> Content
    
    public init(
        axis: Axis.Set = .vertical,
        showsIndicators: Bool = true,
        onScroll: @escaping ScrollAction,
        content: @escaping () -> Content
    ) {
        self.axis = axis
        self.showsIndicators = showsIndicators
        self.onScroll = onScroll
        self.content = content
    }

    public var body: some View {
        ScrollView(axis, showsIndicators: showsIndicators) {
            ScrollViewOffsetTracker()
            
            content()
        }
        .coordinateSpace(name: ScrollViewOffsetTracker.Namespace.id)
        .onPreferenceChange(ScrollViewOffsetTracker.OffsetKey.self, perform: onScroll)
    }
}
