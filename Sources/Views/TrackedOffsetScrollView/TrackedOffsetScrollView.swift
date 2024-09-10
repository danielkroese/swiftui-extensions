import SwiftUI

/// A ScrollView with a callback that returns the current offset CGPoint.
public struct TrackedOffsetScrollView<Content: View>: View {
    public typealias ScrollAction = (_ offset: CGPoint) -> Void
    
    private let axis: Axis.Set
    private let onScroll: ScrollAction
    private let content: () -> Content
    
    /// - Parameters:
    ///   - axes: The scroll view's scrollable axis. The default axis is the vertical axis.
    ///   - onScroll: Callback that returns the current offset CGPoint.
    ///   - content: The view builder that creates the scrollable view.
    public init(
        axis: Axis.Set = .vertical,
        onScroll: @escaping ScrollAction,
        content: @escaping () -> Content
    ) {
        self.axis = axis
        self.onScroll = onScroll
        self.content = content
    }

    public var body: some View {
        ScrollView(axis) {
            ScrollViewOffsetTracker()
            
            content()
        }
        .coordinateSpace(name: ScrollViewOffsetTracker.Namespace.id)
        .onPreferenceChange(ScrollViewOffsetTracker.OffsetKey.self, perform: onScroll)
    }
}
