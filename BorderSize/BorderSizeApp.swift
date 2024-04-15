//
//  BorderSizeApp.swift
//  BorderSize
//
//  Created by Vipul Arvind on 4/13/24.
//

import SwiftUI

@main
struct BorderSizeApp: App {
    @StateObject private var imageProcessorVM = ImageProcessorVM.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(imageProcessorVM)
        }
    }
}
