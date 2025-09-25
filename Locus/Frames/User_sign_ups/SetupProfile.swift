import SwiftUI

struct SetupProfileView: View {
    // Inputs
    @Binding var username: String
    @Binding var university: String
    @Binding var occupation: String
    @Binding var currentCity: String
    @Binding var frequentedCity: String

    // Actions
    var onBack: (() -> Void)?
    var onContinue: (() -> Void)?

    @State private var showValidation = false
    @State private var isKeyboardVisible = false

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            GridBackground()
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    header
                    progressDots
                    Text("you’re almost done:")
                        .font(.custom("JetBrainsMono-Medium", size: 12))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 10)

                    VStack(alignment: .leading, spacing: 36) {
                        LocusField(label: "Create username: *", placeholder: "", text: $username, height: 22)
                            .frame(width: 268)
                            .padding(.top, 20)
                        LocusField(label: "College/University: *", placeholder: "", text: $university, height: 22)
                            .padding(.bottom, 1)
                            .frame(width: 268)
                        LocusField(label: "Occupation/Work: (optional)", placeholder: "", text: $occupation, height: 22)
                            .frame(width: 268)
                        HStack(spacing: 12) {
                            LocusField(label: "Current city: *", placeholder: "", text: $currentCity, height: 22)
                                .frame(width: 143)
                            LocusField(label: "Frequented city: *", placeholder: "", text: $frequentedCity, height: 22)
                                .frame(width: 143)
                        }
                    }

                    HStack(spacing: 14) {
                        Button(action: { onBack?() }) {
                            Text("← back")
                                .font(.custom("JetBrainsMono-Medium", size: 13))
                                .foregroundColor(.white.opacity(0.5))
                                .frame(width: 81, height: 27)
                                .background(Color(hex: "#1a1a19"))
                                .cornerRadius(8)
                        }

                        Spacer(minLength: 0)

                        Button(action: {
                            if isValid() { onContinue?() } else { showValidation = true }
                        }) {
                            HStack(spacing: 8) {
                                Text("Continue to The Grid →")
                                    .font(.custom("JetBrainsMono-Medium", size: 10))
                            }
                            .foregroundColor(.black.opacity(0.7))
                            .frame(width: 194, height: 27)
                            .background(Color(white: 0.9))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.top, 32)

                    Spacer(minLength: 80)
                }
                .padding(.horizontal, 30)
                .padding(.top, 24)
                .frame(maxWidth: 402, alignment: .leading)
                .frame(minHeight: 874, alignment: .topLeading)
            }
            .safeAreaInset(edge: .bottom) {
                // Footer that hides when keyboard is visible
                if !isKeyboardVisible {
                    HStack(spacing: 12) {
                        AppMarkImageView()
                            .frame(width: 60, height: 55)
                            .opacity(0.5)
                        Text("© 2025 Locus Network LLC. All rights reserved.")
                            .font(.custom("JetBrainsMono-Medium", size: 10))
                            .foregroundColor(Color(hex: "#c5c1c1").opacity(0.8))
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 8)
                }
            }

            // removed separate bottom-left app icon to keep footer centered as a group
        }
        .background(Color.black)
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                isKeyboardVisible = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                isKeyboardVisible = false
            }
        }
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Complete Locus Profile")
                .font(.custom("JetBrainsMono-ExtraBold", size: 17))
                .foregroundColor(.white)
                .padding(.top, 12)
                .padding(.horizontal, 1)
            Spacer()
            Text("⟨x,y,z⟩ → ∞")
                .font(.custom("JetBrainsMono-Medium", size: 10))
                .foregroundColor(Color(hex: "#575757"))
        }
    }

    private var progressDots: some View {
        HStack { // center the visual within the container
            Spacer()
            HStack(spacing: 16) {
                Circle().fill(Color.white.opacity(0.5)).frame(width: 6, height: 6)
                Rectangle().fill(Color.white.opacity(0.35)).frame(width: 64, height: 1)
                Circle().fill(Color.white).frame(width: 6, height: 6)
                Rectangle().fill(Color.white.opacity(0.35)).frame(width: 64, height: 1)
                Circle().fill(Color.white.opacity(0.5)).frame(width: 6, height: 6)
            }
            Spacer()
        }
        .padding(.top, 8)
    }

    private func isValid() -> Bool {
        !username.trimmingCharacters(in: .whitespaces).isEmpty &&
        !university.trimmingCharacters(in: .whitespaces).isEmpty &&
        !currentCity.trimmingCharacters(in: .whitespaces).isEmpty &&
        !frequentedCity.trimmingCharacters(in: .whitespaces).isEmpty
    }
}

// MARK: - Subviews

private struct LocusField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var height: CGFloat = 19

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.custom("JetBrainsMono-Medium", size: 13))
                .foregroundColor(.white)
            TextField(placeholder, text: $text)
                .font(.system(size: 12))
                .foregroundColor(.black)
                .padding(.horizontal, 10)
                .frame(height: height, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 7)
                        .fill(Color.white)
                )
                .shadow(color: Color.black.opacity(0.35), radius: 6, x: 0, y: 2)
        }
    }
}



private struct AppMarkImageView: View {
    var body: some View {
        if let uiImage = UIImage(named: "AppMark") {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.7), lineWidth: 1)
                Path { p in
                    let rect = CGRect(x: 6, y: 8, width: 48, height: 38)
                    p.move(to: CGPoint(x: rect.minX, y: rect.maxY))
                    p.addCurve(to: CGPoint(x: rect.maxX, y: rect.minY),
                               control1: CGPoint(x: rect.minX + rect.width * 0.2, y: rect.minY + rect.height * 0.1),
                               control2: CGPoint(x: rect.minX + rect.width * 0.6, y: rect.minY + rect.height * 0.9))
                }
                .stroke(Color.white.opacity(0.7), lineWidth: 1)
            }
        }
    }
}

#Preview {
    StatefulPreviewWrapper("") { username in
        StatefulPreviewWrapper("") { university in
            StatefulPreviewWrapper("") { occupation in
                StatefulPreviewWrapper("") { current in
                    StatefulPreviewWrapper("") { freq in
                        SetupProfileView(
                            username: username,
                            university: university,
                            occupation: occupation,
                            currentCity: current,
                            frequentedCity: freq,
                            onBack: {},
                            onContinue: {}
                        )
                        .preferredColorScheme(.dark)
                    }
                }
            }
        }
    }
}

// Helper to bind simple values in previews
struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State var value: Value
    var content: (Binding<Value>) -> Content
    init(_ value: Value, content: @escaping (Binding<Value>) -> Content) {
        _value = State(initialValue: value)
        self.content = content
    }
    var body: some View { content($value) }
} 
