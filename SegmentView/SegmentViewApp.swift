//
//  SegmentViewApp.swift
//  SegmentView
//
//  Created by Wei Lu on 11/08/2021.
//

import SwiftUI

@main
struct SegmentViewApp: App {
    @State private var select: Int = 0
    private var items = ["A", "ABC", "Long Name", "SN"]

    var body: some Scene {
        WindowGroup {
            VStack {
                SegmentControlView(items: items, selection: $select)
                    .padding(.vertical, 16)

                Text("Page title \"\(items[select])\"")

                Spacer()
            }
        }
    }
}
