//
//  Components.swift
//  sbud
//
//  Created by Erdal on 24.03.2026.
//

import SwiftUI

struct CustomInputField: View {
        let title: String
        let placeholder: String
        @Binding var text: String
        
        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                
                TextField(placeholder, text: $text)
                    .textContentType(.name)
                    .padding(.horizontal, 16)
                    .frame(height: 58)
                    .background(Color("textFieldColor"))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .toolbar {
                                        ToolbarItemGroup(placement: .keyboard) {
                                            Spacer()
                                            Button("Done") {
                                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                            }
                                        }
                                    }
            }
        }
    }
// MARK: - Yardımcı View Bileşeni
@ViewBuilder
func customTextField(title: String, placeholder: String, text: Binding<String>) -> some View {
    VStack(alignment: .leading, spacing: 8) {
        Text(title)
            .font(.system(size: 12, weight: .bold)).foregroundColor(Color.gray).kerning(1.2)
            
        
        TextField("", text: text, prompt:
            Text(placeholder)
                .foregroundColor(Color.white.opacity(0.2))
                .font(.system(size: 24, weight: .bold))
        )
        .padding()
        .frame(height: 60)
        .background(Color.white.opacity(0.08))
        .foregroundColor(.white)
        .cornerRadius(4)
    }
}

    
    struct CustomMultilineField: View {
        let title: String
        let placeholder: String
        @Binding var text: String
        
        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                
                TextField(placeholder, text: $text, axis: .vertical)
                    .lineLimit(3...5)
                    .padding(16)
                    .frame(minHeight: 110, alignment: .topLeading)
                    .background(Color("textFieldColor"))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .toolbar {
                                        ToolbarItemGroup(placement: .keyboard) {
                                            Spacer()
                                            Button("Done") {
                                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                            }
                                        }
                                    }
            }
        }
    }
    
    struct CustomDateField: View {
        let title: String
        @Binding var date: Date?
        let maxDate = Calendar.current.date(byAdding: .year, value: -18, to: Date())!
        
        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                
                DatePicker(
                    "Birth Date",
                    selection: Binding(
                        get: { date ?? maxDate },
                        set: { date = $0 }
                    ),
                    in: ...maxDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .labelsHidden()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .frame(height: 58)
                .background(Color("textFieldColor"))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
    }

    struct CustomPickerField: View {
        let title: String
        @Binding var selection: String
        let options: [String]
        
        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                
                Picker(title, selection: $selection) {
                    ForEach(options, id: \.self) { option in
                        Text(option.isEmpty ? "Select" : option).tag(option)
                    }
                }
                .padding(.horizontal, 8)
                .frame(height: 58)
                .frame(maxWidth: .infinity)
                .background(Color("textFieldColor"))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
    }
    
    struct CustomNumberField: View {
        let title: String
        @Binding var value: Double
        let placeholder: String
        
        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                
                TextField(placeholder, value: $value, format: .number)
                    .keyboardType(.decimalPad)
                    .padding(.horizontal, 16)
                    .frame(height: 58)
                    .background(Color("textFieldColor"))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Bitti") {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                    }
                }
            }
        }
    }
    
struct CustomActivityPicker: View {
    @ObservedObject var vm: ProfileSetupVM
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Preferences & Stats")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.black)
            
            Picker("Activity Type", selection: $vm.profile.preferredActivity) {
                ForEach(ActivityType.allCases, id: \.self) { type in
                    Text(type.rawValue.capitalized).tag(type)
                }
            }
            .padding(.horizontal, 8)
            .frame(height: 58)
            .frame(maxWidth: .infinity)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            
            if vm.profile.preferredActivity == .running {
                CustomInputField(
                    title: "Avg Pace",
                    placeholder: "e.g. 5:45",
                    text: Binding(
                        get: { vm.profile.metrics.averagePace ?? "" },
                        set: { vm.profile.metrics.averagePace = $0 }
                    )
                )
            }
        }
    }
}
