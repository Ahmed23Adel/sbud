//
//  CustomCalendarView.swift
//  sbud
//
//  Created by Erdal on 18.04.2026.
//

import SwiftUI

extension Date {
    func formatMonthYear() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: self).uppercased()
    }
}

struct DateValue: Identifiable {
    var id = UUID().uuidString
    var day: Int
    var date: Date
}

struct CustomCalendarView: View {
    @Binding var selectedDate: Date
    @State private var currentMonth = Date()
    @State private var showYearPicker = false
    
    let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]
    let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    
    var body: some View {
        VStack(spacing: 15) {
            // Header
            HStack {
                Button(action: { withAnimation { showYearPicker.toggle() } }) {
                    HStack(spacing: 5) {
                        Text(currentMonth.formatMonthYear())
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(.white)
                        Image(systemName: "chevron.down.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color("palelime"))
                    }
                }
                Spacer()
                if !showYearPicker {
                    HStack(spacing: 20) {
                        Button(action: { changeMonth(by: -1) }) {
                            Image(systemName: "chevron.left").foregroundColor(.gray)
                        }
                        Button(action: { changeMonth(by: 1) }) {
                            Image(systemName: "chevron.right").foregroundColor(.gray)
                        }
                    }
                }
            }
            .padding(.horizontal, 5)
            
            if showYearPicker {
                // Hızlı Yıl ve Ay Seçimi
                VStack(spacing: 0) {
                    DatePicker("", selection: $currentMonth, displayedComponents: .date)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        // colorInvert yerine sadece içeriği beyaz yapmak için:
                        .colorInvert()
                        // 60 yerine en az 150-180 arası bir değer idealdir
                        .frame(height: 150)
                        .clipped() // Picker'ın sınır dışına taşmasını engeller
                        .scaleEffect(0.9) // Çok büyük gelirse buradan ölçekleyebilirsin
                    
                    Button(action: {
                        withAnimation {
                            selectedDate = currentMonth
                            showYearPicker = false
                        }
                    }) {
                        Text("DONE")
                            .font(.system(size: 14, weight: .black))
                            .foregroundColor(Color("palelime"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .cornerRadius(8)
                    }
                    .padding(.top, 5)
                }
                .padding(.bottom, 5)
            } else {
                // Gün Izgarası
                VStack(spacing: 10) {
                    HStack(spacing: 0) {
                        ForEach(daysOfWeek, id: \.self) { day in
                            Text(day).font(.system(size: 10, weight: .bold))
                                .foregroundColor(.gray.opacity(0.6)).frame(maxWidth: .infinity)
                        }
                    }
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(extractDays()) { value in
                            dayView(value: value)
                        }
                    }
                }
            }
        }
        .padding(15)
        .background(Color(white: 0.1))
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.1), lineWidth: 1))
    }
    
    @ViewBuilder
    func dayView(value: DateValue) -> some View {
        ZStack {
            if value.day != -1 {
                let isSelected = Calendar.current.isDate(value.date, inSameDayAs: selectedDate)
                Text("\(value.day)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(isSelected ? .black : .white)
                    .frame(width: 28, height: 28) // Rakamların bölünmemesi için genişletildi
                    .background(RoundedRectangle(cornerRadius: 4).fill(isSelected ? Color("palelime") : Color.clear))
                    .onTapGesture { selectedDate = value.date }
            }
        }
        .frame(height: 35)
    }
    
    private func changeMonth(by value: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: value, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    private func extractDays() -> [DateValue] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: currentMonth)
        let startOfMonth = calendar.date(from: components)!
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
        var dateValues = range.compactMap { day -> DateValue in
            let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)!
            return DateValue(day: day, date: date)
        }
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        for _ in 0..<firstWeekday - 1 {
            dateValues.insert(DateValue(day: -1, date: Date()), at: 0)
        }
        return dateValues
    }
}
