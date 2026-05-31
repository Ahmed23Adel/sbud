//
//  StoryCaptionFieldView.swift
//  sbud
//

import SwiftUI

struct StoryCaptionFieldView: View {
    @Binding var caption: String
    @State private var shakeOffset: CGFloat = 0
    let maxChars = 500

    var body: some View {
        VStack(spacing: 0) {
            GenericMultilineTextInputView(
                fieldName: "Caption",
                placeholder: "What happened?",
                iconString: "text.alignleft",
                text: $caption
            )
            .offset(x: shakeOffset)
            .onChange(of: caption) { _, new in
                if new.count > maxChars {
                    caption = String(new.prefix(maxChars))
                    triggerShake()
                    PopUpGenerator.shared.show(msg: "Caption can't exceed \(maxChars) characters", type: .error)
                }
            }

            HStack {
                Spacer()
                Text("\(caption.count)/\(maxChars)")
                    .font(.caption2)
                    .foregroundColor(caption.count >= (maxChars - 20) ? Color.mainColor : .white.opacity(0.3))
            }
            .padding(.horizontal, 30)
            .padding(.top, 4)
        }
    }

    private func triggerShake() {
        let animation = Animation.easeInOut(duration: 0.07)
        withAnimation(animation) { shakeOffset = -10 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.07) {
            withAnimation(animation) { shakeOffset = 10 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) {
            withAnimation(animation) { shakeOffset = -6 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.21) {
            withAnimation(animation) { shakeOffset = 6 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
            withAnimation(animation) { shakeOffset = 0 }
        }
    }
}

#Preview("Empty") {
    StoryCaptionFieldView(caption: .constant(""))
        .padding()
        .background(Color.darkBackground)
}

#Preview("With text") {
    StoryCaptionFieldView(caption: .constant("Just finished a great 10k run with the crew!"))
        .padding()
        .background(Color.darkBackground)
}

#Preview("At limit") {
    StoryCaptionFieldView(caption: .constant(String(repeating: "a", count: 500)))
        .padding()
        .background(Color.darkBackground)
}
