import SwiftUI

public struct StretchableHeaderScrollView<Content: View, Header: View>: View {
    public typealias ScrollAction = (_ offset: CGPoint, _ headerVisibilityRatio: CGFloat) -> Void
    
    let header: () -> Header
    let content: () -> Content
    let onScroll: ScrollAction
    
    @State private var navigationBarHeight: CGFloat = .zero
    @State private var headerHeight: CGFloat = .zero
    @State private var scrollOffset: CGPoint = .zero
    
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
                    onScroll(.zero, headerVisibilityRatio)
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
        
        onScroll(offset, headerVisibilityRatio)
    }
    
    private var headerVisibilityRatio: CGFloat {
        max(.zero, (headerHeight + scrollOffset.y) / headerHeight)
    }
}
