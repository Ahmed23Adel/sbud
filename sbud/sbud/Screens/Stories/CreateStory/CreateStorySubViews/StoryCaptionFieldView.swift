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
        VStack(alignment: .leading, spacing: 8) {
            Label("Caption", systemImage: "text.alignleft")
                .font(.subheadline.bold())
                .foregroundStyle(.white)

            ZStack(alignment: .topLeading) {
                if caption.isEmpty {
                    Text("What happened?")
                        .foregroundStyle(.white.opacity(0.3))
                        .font(.subheadline)
                        .padding(.top, 1)
                        .padding(.leading, 4)
                }
                TextEditor(text: $caption)
                    .scrollContentBackground(.hidden)
                    .foregroundStyle(.white)
                    .tint(Color.mainColor)
                    .font(.subheadline)
                    .frame(minHeight: 70)
                    .onChange(of: caption) { _, new in
                        if new.count > maxChars {
                            caption = String(new.prefix(maxChars))
                            triggerShake()
                            PopUpGenerator.shared.show(msg: "Caption can't exceed \(maxChars) characters", type: .error)
                        }
                    }
            }
            .padding(14)
            .background(Color.blackBackground, in: RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
            )
            .offset(x: shakeOffset)

            HStack {
                Spacer()
                Text("\(caption.count)/\(maxChars)")
                    .font(.caption2)
                    .foregroundStyle(caption.count >= (maxChars - 20) ? Color.mainColor : .white.opacity(0.3))
            }
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
