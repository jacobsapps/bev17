//
//  BevApp.swift
//  Bev
//
//  Created by Jacob Bartlett on 01/04/2023.
//

import SwiftUI

@main
struct BevApp: App {
    
    init() {
        if ProcessInfo.processInfo.arguments.contains("UI-TESTING") {
           UIView.setAnimationsEnabled(false)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            BeerListView()
        }
    }
}
