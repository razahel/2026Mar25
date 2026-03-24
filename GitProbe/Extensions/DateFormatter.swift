//
//  DateFormatter.swift
//  GitProbe
//
//  Created by Yoon Kang on 25/3/26.
//

import Foundation

extension DateFormatter {
  static let monthDate: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM. dd."
    return formatter
  }()
}
