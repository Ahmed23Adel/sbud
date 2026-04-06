//
//  PhoneNumberView.swift
//  sbud
//
//  Created by Erdal on 22.03.2026.
//
import SwiftUI
import PhoneNumberKit

struct PhoneNumberView: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String = "Phone Number"

    func makeUIView(context: Context) -> PhoneNumberTextField {
        let textField = PhoneNumberTextField()
        textField.flagButton.isUserInteractionEnabled = false

        textField.withFlag = true
        textField.withExamplePlaceholder = true
        textField.withPrefix = true
        textField.withDefaultPickerUI = true
        //textField.keyboardType = .phonePad
        textField.placeholder = placeholder
        textField.borderStyle = .none
        textField.font = .systemFont(ofSize: 16, weight: .regular)

        textField.addTarget(
            context.coordinator,
            action: #selector(Coordinator.textDidChange(_:)),
            for: .editingChanged
        )

        return textField
    }

    func updateUIView(_ uiView: PhoneNumberTextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    final class Coordinator: NSObject {
        @Binding var text: String

        init(text: Binding<String>) {
            self._text = text
        }

        @objc func textDidChange(_ textField: UITextField) {
            text = textField.text ?? ""
        }
    }
}
