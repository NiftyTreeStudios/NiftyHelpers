//
//  View+Ext.swift
//  
//
//  Created by Iiro Alhonen on 11.4.2022.
//

import SwiftUI

@available(macOS 10.15, *)
public extension View {
    /**
     Applies the given modifier if the given condition evaluates to `true`.

     - Parameters:
        - condition: The condition to evaluate.
        - transform: The modifier to add to the source `View`.
     - Returns: Either the original `View` or the modified `View` if the condition is `true`.
     */
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
