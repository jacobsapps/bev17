//
//  View+Extensions.swift
//  Bev
//
//  Created by Jacob Bartlett on 13/10/2023.
//

import SwiftUI

extension View {
    
    @ViewBuilder
    func `if`<Content: View>(
        _ conditional: Bool,
        content: (Self) -> Content
    ) -> some View {
        if conditional {
            content(self)
        } else {
            self
        }
    }
}
