//
//  SegmentControView.swift
//  CommonUI
//
//  Created by Wei Lu on 11/08/2021.
//

import SwiftUI

/// PreferenceKey for a subview to notify superview of its size
private struct SizePreferenceKey: PreferenceKey {
    public typealias Value = CGSize
    public static var defaultValue: Value = .zero
    
    public static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }
}

private struct BackgroundGeometryReader: View {
    public init() {}
    
    public var body: some View {
        GeometryReader { geometry in
            return Color
                .clear
                .preference(key: SizePreferenceKey.self, value: geometry.size)
        }
    }
}

public struct SegmentControlView: View {
    
    private let items: [String]
    @Binding private var selection: Int
    @State private var segmentSize: CGSize = .zero
    @State private var itemTitleSizes: [CGSize] = []
    
    /// using the value to set a fix horizontal space for items.
    /// the view will show as center of all items if `defaultXSpace` is nil
    /// otherwise, will show items on leading with give space.
    private let defaultXSpace: CGFloat?
    
    public init(
        items: [String],
        selection: Binding<Int>,
        defaultXSpace: CGFloat? = nil
    ) {
        self._selection = selection
        self.items = items
        self.defaultXSpace = defaultXSpace
        self._itemTitleSizes = State(initialValue: [CGSize](repeating: .zero, count: items.count))
    }
    
    public var body: some View {
        VStack(alignment: defaultXSpace == nil ? .center : .leading, spacing: 0) {
            GeometryReader { geometry in
                Color
                    .clear
                    .onAppear {
                        segmentSize = geometry.size
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: 1)

            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: xSpace) {
                        ForEach(0 ..< items.count, id: \.self) { index in
                            segmentItemView(for: index)
                        }
                    }
                    .padding(.bottom, 12)
                    
                    // bottom line
                    Rectangle()
                        .foregroundColor(.black)
                        .frame(width: selectedItemWidth, height: 3)
                        .offset(x: selectedItemHorizontalOffset(), y: 0)
                        .animation(Animation.linear(duration: 0.3))
                }
                .padding(.horizontal, xSpace)
            }
        }
    }
    
    private var selectedItemWidth: CGFloat {
        return itemTitleSizes.count > selection ? itemTitleSizes[selection].width : .zero
    }
    
    @ViewBuilder
    private func segmentItemView(for index: Int) -> some View {
        let isSelected = self.selection == index
        
        Text(items[index])
            .font(.caption)
            .foregroundColor(isSelected ? .blue : .gray)
            .background(BackgroundGeometryReader())
            .onPreferenceChange(SizePreferenceKey.self) {
                itemTitleSizes[index] = $0
            }
            .onTapGesture { onItemTap(index: index) }
    }
    
    private func onItemTap(index: Int) {
        guard index < self.items.count else { return }
        self.selection = index
    }
    
    private var xSpace: CGFloat {
        if let defaultXSpace {
            return defaultXSpace
        }
        
        guard !itemTitleSizes.isEmpty, !items.isEmpty, segmentSize.width != 0 else { return 0 }
        let itemWidthSum: CGFloat = itemTitleSizes.map { $0.width }.reduce(0, +).rounded()
        let space = (segmentSize.width - itemWidthSum) / CGFloat(items.count + 1)
        return max(space, 0)
    }
    
    private func selectedItemHorizontalOffset() -> CGFloat {
        guard selectedItemWidth != .zero, selection != 0 else { return 0 }
        
        let result = itemTitleSizes
            .enumerated()
            .filter { $0.offset < selection }
            .map { $0.element.width }
            .reduce(0, +)
        
        return result + xSpace * CGFloat(selection)
    }
}

struct SegmentControlView_Previews: PreviewProvider {
    static var previews: some View {
        SegmentControlView(items: ["A", "ABC", "Long Name", "SN"], selection: .constant(1), defaultXSpace: 20)
    }
}
