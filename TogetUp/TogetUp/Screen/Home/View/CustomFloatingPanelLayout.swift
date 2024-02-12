//
//  CustomFloatingPanelLayout.swift
//  TogetUp
//
//  Created by 이예원 on 2/6/24.
//

import Foundation
import FloatingPanel

class CustomFloatingPanelLayout: FloatingPanelLayout {
    var position: FloatingPanelPosition {
        return .bottom
    }
    
    var initialState: FloatingPanelState {
        return .tip
    }
    
    var anchors: [FloatingPanelState : FloatingPanelLayoutAnchoring] {
        return [
            .full: FloatingPanelLayoutAnchor(absoluteInset: 80,  edge: .top, referenceGuide: .safeArea),
            .half: FloatingPanelLayoutAnchor(absoluteInset: 175, edge: .bottom, referenceGuide: .safeArea),
            .tip: FloatingPanelLayoutAnchor(absoluteInset: 175, edge: .bottom, referenceGuide: .safeArea)
        ]
    }
    
    func backdropAlpha(for state: FloatingPanelState) -> CGFloat {
        return state == .full ? 0.3 : 0.0
    }
}
