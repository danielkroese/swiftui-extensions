import SwiftUI

/// A ScrollView with a header that stretches out when pulling down.
public struct StretchableHeaderScrollView<Content: View, Header: View>: View {
    public typealias ScrollAction = (_ offset: CGPoint, _ headerVisibilityRatio: CGFloat) -> Void
    
    @State private var navigationBarHeight: CGFloat = .zero
    @State private var headerHeight: CGFloat = .zero
    @State private var scrollOffset: CGPoint = .zero
    
    private let header: () -> Header
    private let content: () -> Content
    private let onScroll: ScrollAction?
    
    /// - Parameters:
    ///   - header: The view builder that creates the stretching header.
    ///   - content: The view builder that creates the scrollable view.
    ///   - onScroll: Callback that returns the current offset CGPoint and the ratio of header visibility.
    public init(
        header: @escaping () -> Header,
        content: @escaping () -> Content,
        onScroll: ScrollAction? = nil
    ) {
        self.header = header
        self.content = content
        self.onScroll = onScroll
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            scrollView
            
            navbarOverlay
        }
    }
    
    private var scrollView: some View {
        GeometryReader { proxy in
            TrackedOffsetScrollView(onScroll: handleScroll) {
                VStack(spacing: .zero) {
                    scrollHeader
                    
                    content()
                }
            }
            .onAppear {
                let height = proxy.safeAreaInsets.top
                Task { @MainActor in
                    navigationBarHeight = height
                    onScroll?(.zero, headerVisibilityRatio)
                }
            }
        }
        .ignoresSafeArea(.container, edges: .top)
    }
    
    private var scrollHeader: some View {
        GeometryReader { geometry in
            let topOverflow = geometry.frame(in: .named(ScrollViewOffsetTracker.Namespace.id)).minY
            let stretchAmount = max(.zero, topOverflow)
            
            header()
                .frame(height: geometry.size.height + stretchAmount)
                .offset(y: -stretchAmount)
                .onChange(of: geometry.size.height) { newValue in
                    Task { @MainActor in
                        headerHeight = newValue
                    }
                }
                .onAppear {
                    let height = geometry.size.height
                    Task { @MainActor in
                        headerHeight = height
                    }
                }
        }
        .aspectRatio(contentMode: .fill)
    }
    
    @ViewBuilder
    private var navbarOverlay: some View {
        if headerVisibilityRatio <= .zero {
            Color.clear
                .frame(height: navigationBarHeight)
                .overlay(scrollHeader, alignment: .bottom)
                .ignoresSafeArea(.container, edges: .top)
        }
    }
    
    private func handleScroll(_ offset: CGPoint) {
        scrollOffset = offset
        
        onScroll?(offset, headerVisibilityRatio)
    }
    
    private var headerVisibilityRatio: CGFloat {
        max(.zero, (headerHeight + scrollOffset.y) / headerHeight)
    }
}
