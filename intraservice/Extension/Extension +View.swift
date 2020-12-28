//
//  Extension +View.swift
//  intraservice
//
//  Created by Vladlen Sukhov on 27.12.2020.
//

import SwiftUI

extension View {
    @ViewBuilder func hidden(_ shouldHide: Bool) -> some View {
        switch shouldHide {
        case true: self.hidden()
        case false: self
        }
    }
}
