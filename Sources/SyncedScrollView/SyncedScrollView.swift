import SwiftUI

/// A custom view that synchronizes scrolling across multiple content views.
///
/// - Parameters:
///   - content: The main scrollable content.
///   - vSyncedContent: The content that synchronizes vertically.
///   - hSyncedContent: The content that synchronizes horizontally.
///   - topLeftContent: The content displayed in the top-left corner (default is `EmptyView`).
public struct SyncedScrollView<
    Content: View,
    VSyncedContent: View,
    HSyncedContent: View,
    TopLeftContent: View
>: View {
    private let content: Content
    private let vSyncedContent: VSyncedContent
    private let hSyncedContent: HSyncedContent
    private let topLeftContent: TopLeftContent

    @State private var vSyncedContentSize: CGSize = .zero
    @State private var hSyncedContentSize: CGSize = .zero
    @State private var contentSize: CGSize = .zero
    @State private var offset: CGPoint = .zero

    private var viewSize: CGSize {
        .init(
            width: vSyncedContentSize.width + contentSize.width,
            height: hSyncedContentSize.height + contentSize.height
        )
    }

    public init(
        @ViewBuilder _ content: () -> Content,
        @ViewBuilder vSyncedContent: () -> VSyncedContent,
        @ViewBuilder hSyncedContent: () -> HSyncedContent,
        @ViewBuilder topLeftContent: () -> TopLeftContent = { EmptyView() }
    ) {
        self.content = content()
        self.vSyncedContent = vSyncedContent()
        self.hSyncedContent = hSyncedContent()
        self.topLeftContent = topLeftContent()
    }

    public var body: some View {
        ZStack(alignment: .topLeading) {
            // The actual scrollable content
            HStack(alignment: .top, spacing: 0) {
                LeftContent(
                    topLeftContent: topLeftContent,
                    vSyncedContent: vSyncedContent,
                    yOffset: offset.y,
                    vSyncedContentSize: $vSyncedContentSize
                )
                .offset(x: offset.x < 0 ? -offset.x : 0)

                RightContent(
                    hSyncedContent: hSyncedContent,
                    content: content,
                    offset: offset,
                    hSyncedContentSize: $hSyncedContentSize,
                    contentSize: $contentSize
                )
            }

            // A hidden view that tracks scroll position
            ObservableScrollView(
                viewSize: viewSize,
                offset: $offset
            )
        }
    }

    /// The fixed scrollable content on the left side.
    struct LeftContent: View {
        let topLeftContent: TopLeftContent
        let vSyncedContent: VSyncedContent
        let yOffset: CGFloat
        @Binding var vSyncedContentSize: CGSize

        var body: some View {
            VStack(spacing: 0) {
                topLeftContent

                ScrollView {
                    vSyncedContent
                        .offset(y: -yOffset)
                        .overlay(
                            GeometryReader { geometry in
                                Color.clear.preference(
                                    key: VSyncedContentSizeKey.self,
                                    value: geometry.size
                                )
                            }
                        )
                }
                .disabled(true)
                .onPreferenceChange(VSyncedContentSizeKey.self) { size in
                    vSyncedContentSize = size
                }
            }
        }
    }

    /// The right side containing the main scrollable content.
    struct RightContent: View {
        let hSyncedContent: HSyncedContent
        let content: Content
        let offset: CGPoint
        @Binding var hSyncedContentSize: CGSize
        @Binding var contentSize: CGSize

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                ScrollView(.horizontal) {
                    hSyncedContent
                        .offset(x: -offset.x)
                        .overlay(
                            GeometryReader { geometry in
                                Color.clear.preference(
                                    key: HSyncedContentSizeKey.self,
                                    value: geometry.size
                                )
                            }
                        )
                }
                .disabled(true)
                .onPreferenceChange(HSyncedContentSizeKey.self) { size in
                    self.hSyncedContentSize = size
                }

                ScrollView([.vertical, .horizontal]) {
                    content
                        .offset(x: -offset.x, y: -offset.y)
                        .overlay(
                            GeometryReader { geometry in
                                Color.clear.preference(
                                    key: ContentSizeKey.self,
                                    value: geometry.size
                                )
                            }
                        )
                }
                .frame(maxWidth: contentSize.width, maxHeight: contentSize.height)
                .disabled(true)
                .onPreferenceChange(ContentSizeKey.self) { size in
                    contentSize = size
                }
            }
        }
    }

    /// A hidden view that tracks the scroll offset.
    struct ObservableScrollView: View {
        let viewSize: CGSize
        private let spaceName = "scroll"

        @Binding var offset: CGPoint

        var body: some View {
            ScrollView([.vertical, .horizontal]) {
                Color.clear
                    .frame(width: viewSize.width, height: viewSize.height)
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .preference(
                                    key: ObservableViewOffsetKey.self,
                                    value: CGPoint(
                                        x: -geometry.frame(in: .named(spaceName)).origin.x,
                                        y: -geometry.frame(in: .named(spaceName)).origin.y
                                    )
                                )
                        }
                    )
                    .onPreferenceChange(ObservableViewOffsetKey.self) { offset in
                        self.offset = offset
                    }
            }
            .frame(maxWidth: viewSize.width, maxHeight: viewSize.height)
            .coordinateSpace(name: spaceName)
        }
    }
}

extension CGSize {
    /// Extension to add two `CGSize` values.
    fileprivate static func + (lhs: Self, rhs: Self) -> Self {
        .init(
            width: lhs.width + rhs.width,
            height: lhs.height + rhs.height
        )
    }
}

// MARK: - Previews

#Preview("With TopLeftCell") {
    let tableWidth: CGFloat = 40
    let tableHeight: CGFloat = 40
    let cellCount = 20

    SyncedScrollView {
        LazyHStack(spacing: 0) {
            ForEach(1...cellCount, id: \.self) { column in
                LazyVStack(spacing: 0) {
                    ForEach(1...cellCount, id: \.self) { row in
                        Text("R:\(row)\nC:\(column)")
                            .frame(width: tableWidth, height: tableHeight)
                    }
                    .background(.green)
                }
            }
        }
    } vSyncedContent: {
        LazyVStack(spacing: 0) {
            ForEach(1...cellCount, id: \.self) { row in
                Text("R:\(row)\nC:\(0)")
                    .frame(width: tableWidth, height: tableHeight)
            }
            .background(.pink)
        }
        .frame(width: tableWidth)
    } hSyncedContent: {
        LazyHStack(spacing: 0) {
            ForEach(1...cellCount, id: \.self) { column in
                Text("R:\(0)\nC:\(column)")
                    .frame(width: tableWidth, height: tableHeight)
            }
            .background(.yellow)
        }
        .frame(height: tableHeight)
    } topLeftContent: {
        Text("R:\(0)\nC:\(0)")
            .frame(width: tableWidth, height: tableHeight)
            .background(.blue)
    }
}

#Preview("Without TopLeftCell") {
    let tableWidth: CGFloat = 40
    let tableHeight: CGFloat = 40
    let cellCount = 20

    SyncedScrollView {
        LazyHStack(spacing: 0) {
            ForEach(1...cellCount, id: \.self) { column in
                LazyVStack(spacing: 0) {
                    ForEach(1...cellCount, id: \.self) { row in
                        Text("R:\(row)\nC:\(column)")
                            .frame(width: tableWidth, height: tableHeight)
                    }
                    .background(.green)
                }
            }
        }
    } vSyncedContent: {
        LazyVStack(spacing: 0) {
            ForEach(1...cellCount + 1, id: \.self) { row in
                Text("R:\(row)\nC:\(0)")
                    .frame(width: tableWidth, height: tableHeight)
            }
            .background(.pink)
        }
        .frame(width: tableWidth)
    } hSyncedContent: {
        LazyHStack(spacing: 0) {
            ForEach(1...cellCount, id: \.self) { column in
                Text("R:\(0)\nC:\(column)")
                    .frame(width: tableWidth, height: tableHeight)
            }
            .background(.yellow)
        }
        .frame(height: tableHeight)
    } topLeftContent: {
        EmptyView()
    }
}

