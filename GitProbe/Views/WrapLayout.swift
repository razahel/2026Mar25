//
//  Layout.swift
//  GitProbe
//
//  Created by Yoon Kang on 25/3/26.
//

import SwiftUI

struct WrapLayout: Layout {
  let spacing: CGFloat
  let lineSpacing: CGFloat
  
  init(spacing: CGFloat = 8, lineSpacing: CGFloat = 8) {
    self.spacing = spacing
    self.lineSpacing = lineSpacing
  }
  
  func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout ()
  ) -> CGSize {
    guard let maxWidth = proposal.width, maxWidth > 0 else {
      let widths = subviews.map { $0.sizeThatFits(.unspecified).width }
      let heights = subviews.map { $0.sizeThatFits(.unspecified).height }
      return CGSize(width: widths.reduce(0, +), height: heights.max() ?? 0)
    }
    
    var currentX: CGFloat = 0
    var currentY: CGFloat = 0
    var rowHeight: CGFloat = 0
    
    for subview in subviews {
      let size = subview.sizeThatFits(.unspecified)
      if currentX + size.width > maxWidth, currentX > 0 {
        currentX = 0
        currentY += rowHeight + lineSpacing
        rowHeight = 0
      }
      
      currentX += size.width + spacing
      rowHeight = max(rowHeight, size.height)
    }
    
    return CGSize(width: maxWidth, height: currentY + rowHeight)
  }
  
  func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout ()
  ) {
    var currentX = bounds.minX
    var currentY = bounds.minY
    var rowHeight: CGFloat = 0
    
    for subview in subviews {
      let size = subview.sizeThatFits(.unspecified)
      if currentX + size.width > bounds.maxX, currentX > bounds.minX {
        currentX = bounds.minX
        currentY += rowHeight + lineSpacing
        rowHeight = 0
      }
      
      subview.place(
        at: CGPoint(x: currentX, y: currentY),
        proposal: ProposedViewSize(size)
      )
      currentX += size.width + spacing
      rowHeight = max(rowHeight, size.height)
    }
  }
}

