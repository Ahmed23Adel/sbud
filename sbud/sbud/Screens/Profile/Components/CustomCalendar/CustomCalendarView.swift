//
//  CustomCalendarView.swift
//  sbud
//
//  Created by Erdal on 18.04.2026.
//
import SwiftUI
// MARK: - ViewModel



// MARK: - View

struct CustomCalendarView: View {
    @Binding var selectedDate: Date
    @State private var vm = DatePickerViewModel()

    var body: some View {
        DatePicker("", selection: $vm.selectedDate, displayedComponents: .date)
            .datePickerStyle(.wheel)  
            .colorScheme(.dark)
            .labelsHidden()
            .onAppear { vm.selectedDate = selectedDate }
            .onChange(of: vm.selectedDate) { _, new in selectedDate = new }
    }
}
