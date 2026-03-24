//
//  DateFormatterTests.swift
//  GitProbeTests
//

import Foundation
import Testing
@testable import GitProbe

struct DateFormatterTests {
  @Test
  func monthDateUsesExpectedFormatPattern() {
    #expect(DateFormatter.monthDate.dateFormat == "MM. dd.")
  }
}
