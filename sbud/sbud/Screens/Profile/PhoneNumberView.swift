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
    //var placeholder: String = "Phone Number"

    func makeUIView(context: Context) -> PhoneNumberTextField {
        let textField = PhoneNumberTextField()
        textField.flagButton.isUserInteractionEnabled = false

        textField.withFlag = true
        textField.withExamplePlaceholder = true
        textField.withPrefix = true
        textField.withDefaultPickerUI = true
        //textField.keyboardType = .phonePad
        //textField.placeholder = placeholder
        textField.borderStyle = .none
        textField.font = .systemFont(ofSize: 16, weight: .semibold)
        textField.textColor = .white
        textField.tintColor = UIColor(named: "turquoise") ?? .cyan
        

        textField.addTarget(
            context.coordinator,
            action: #selector(Coordinator.textDidChange(_:)),
            for: .editingChanged
        )
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.barStyle = .black
        toolbar.isTranslucent = true

        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: context.coordinator,
            action: #selector(Coordinator.dismissKeyboard)
        )
        doneButton.tintColor = UIColor(named: "palelime") ?? .systemGreen
        toolbar.items = [spacer, doneButton]

        textField.inputAccessoryView = toolbar

        return textField
    }

    /*func updateUIView(_ uiView: PhoneNumberTextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
    }*/
    
    func updateUIView(_ uiView: PhoneNumberTextField, context: Context) {
        guard !uiView.isFirstResponder else { return }
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
        
        @objc func dismissKeyboard() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }

        @objc func textDidChange(_ textField: UITextField) {
            text = textField.text ?? ""
        }
    }
}
