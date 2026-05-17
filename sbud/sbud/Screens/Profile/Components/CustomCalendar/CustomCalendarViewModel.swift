//
//  CustomCalendarViewModel.swift
//  sbud
//
//  Created by ahmed on 14/05/2026.
//

import Foundation
@Observable
final class DatePickerViewModel {
    var selectedDate: Date

    init(selectedDate: Date = Date()) {
        self.selectedDate = selectedDate
    }
}
