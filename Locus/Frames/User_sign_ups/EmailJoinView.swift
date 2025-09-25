import SwiftUI
import UIKit

struct EmailJoinView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email: String = ""
    @State private var age: String = ""
    @State private var fullName: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showingFinishProfile: Bool = false
    @State private var fpUsername: String = ""
    @State private var fpUniversity: String = ""
    @State private var fpOccupation: String = ""
    @State private var fpCurrentCity: String = ""
    @State private var fpFrequentedCity: String = ""
    
    // Focus state for keyboard management
    @FocusState private var focusedField: Field?
    @State private var isKeyboardVisible = false
    
    enum Field {
        case email, age, fullName, password, confirmPassword
    }
    
    // Computed property to check if all required fields are filled
    private var isFormValid: Bool {
        !email.isEmpty && 
        !age.isEmpty && 
        !fullName.isEmpty && 
        !password.isEmpty && 
        !confirmPassword.isEmpty &&
        password == confirmPassword
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            GridBackground().ignoresSafeArea()
        }
        .overlay(content)
        .sheet(isPresented: $showingFinishProfile) {
            SetupProfileView(
                username: $fpUsername,
                university: $fpUniversity,
                occupation: $fpOccupation,
                currentCity: $fpCurrentCity,
                frequentedCity: $fpFrequentedCity,
                onBack: { showingFinishProfile = false },
                onContinue: {
                    NotificationCenter.default.post(name: .userCompletedOnboarding, object: nil)
                    showingFinishProfile = false
                    dismiss()
                }
            )
            .preferredColorScheme(.dark)
        }
    }
    
    @ViewBuilder
    private var content: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Join with email")
                    .font(.custom("JetBrainsMono-ExtraBold", size: 18))
                    .foregroundColor(.white)
                Spacer()
                Text("⟨x,y,z⟩ → ∞")
                    .font(.custom("JetBrainsMono-Regular", size: 10))
                    .foregroundColor(Color(red: 0.34, green: 0.34, blue: 0.34))
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            
            DecorativeLineDots()
                .padding(.top, 30)
            
            // Subtitle
            Text("hey, let’s get some of your info:")
                .font(.custom("JetBrainsMono-Medium", size: 12))
                .foregroundColor(.white.opacity(0.8))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 36)
            
            VStack(spacing: 0) {
                // Form content with proper keyboard avoidance
                GeometryReader { geo in
                    let contentWidth = geo.size.width - 40 // 20pt side padding on each side
                    let columnSpacing: CGFloat = 32
                    let columnWidth = max(0, (contentWidth - columnSpacing) / 2)
                    let fullNameWidth = max(0, min(contentWidth, 360)) // make longer than one column
                    
                    ScrollView {
                        VStack(spacing: 28) {
                            // Row 1: Email | Age
                            HStack(alignment: .top, spacing: columnSpacing) {
                                labeledField(title: "Enter email:", text: $email, width: min(columnWidth, 110), height: 25, field: .email)
                                    .frame(width: columnWidth, alignment: .leading)
                                labeledField(title: "Enter age:", text: $age, width: min(columnWidth, 110), height: 25, keyboard: .numberPad, field: .age)
                                    .frame(width: columnWidth, alignment: .trailing)
                            }
                            
                            // Row 2: Full name spanning beyond left column
                            HStack(alignment: .top, spacing: 0) {
                                labeledField(title: "Enter full name:", text: $fullName, width: fullNameWidth, height: 25, field: .fullName)
                                Spacer()
                            }
                            
                            // Row 3: Create | Confirm password
                            HStack(alignment: .top, spacing: columnSpacing) {
                                labeledSecure(title: "Create password:", text: $password, width: min(columnWidth, 130), height: 25, field: .password)
                                    .frame(width: columnWidth, alignment: .leading)
                                labeledSecure(title: "Confirm password:", text: $confirmPassword, width: min(columnWidth, 133), height: 25, field: .confirmPassword)
                                    .frame(width: columnWidth, alignment: .trailing)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .top)
                        .padding(.horizontal, 20)
                        .padding(.top, 50)
                        .padding(.bottom, 200) // Extra bottom padding for keyboard
                    }
                    .scrollDismissesKeyboard(.interactively)
                }
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") {
                            focusedField = nil
                        }
                        .font(.custom("JetBrainsMono-Medium", size: 14))
                        .foregroundColor(.white)
                    }
                }
                
                // Fixed bottom section with buttons
                VStack(spacing: 12) {
                    // Validation message - hide when keyboard is visible
                    if !isFormValid && !isKeyboardVisible {
                        Text("Please fill in all fields to continue")
                            .font(.custom("JetBrainsMono-Medium", size: 11))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    
                    HStack(spacing: 24) {
                        Button(action: { dismiss() }) {
                            HStack { Image(systemName: "arrow.left"); Text("back").font(.custom("JetBrainsMono-Regular", size: 13)) }
                                .foregroundColor(.white.opacity(0.85))
                                .frame(width: 150, height: 36)
                                .background(RoundedRectangle(cornerRadius: 8).fill(Color(red: 0.10, green: 0.10, blue: 0.10)))
                        }
                        Button(action: { 
                            if isFormValid {
                                showingFinishProfile = true 
                            }
                        }) {
                            HStack { 
                                Text("continue").font(.custom("JetBrainsMono-Medium", size: 12))
                                Image(systemName: "arrow.right") 
                            }
                            .foregroundColor(isFormValid ? .black : .gray)
                            .frame(width: 150, height: 36)
                            .background(RoundedRectangle(cornerRadius: 8).fill(isFormValid ? Color(white: 0.9) : Color(white: 0.5)))
                        }
                        .disabled(!isFormValid)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .background(Color.black) // Ensure background covers the fixed area
            }
            .safeAreaInset(edge: .bottom) {
                // Footer that hides when keyboard is visible
                if !isKeyboardVisible {
                    HStack {
                        AppMarkImage()
                            .frame(width: 60, height: 55)
                            .opacity(0.5)
                        Spacer()
                        Text("© 2025 Locus Network LLC. All rights reserved.")
                            .font(.custom("JetBrainsMono-Regular", size: 10))
                            .foregroundColor(Color(red: 0.77, green: 0.76, blue: 0.76).opacity(0.8))
                    }
                    .padding(.horizontal, 26)
                    .padding(.bottom, 12)
                    .background(Color.black)
                }
            }
        }
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
    
    private func labeledField(title: String, text: Binding<String>, width: CGFloat, height: CGFloat = 30, keyboard: UIKeyboardType = .default, field: Field) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.custom("JetBrainsMono-Medium", size: 13))
                .foregroundColor(.white)
            TextField("", text: text)
                .keyboardType(keyboard)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .focused($focusedField, equals: field)
                .padding(.horizontal, 10)
                .frame(width: width, height: height, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 5).fill(Color.white.opacity(0.95)))
                .foregroundColor(.black)
                .font(.custom("JetBrainsMono-Regular", size: 12))
        }
    }
    
    private func labeledFieldFullWidth(title: String, text: Binding<String>, width: CGFloat, height: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.custom("JetBrainsMono-Medium", size: 13))
                .foregroundColor(.white)
            TextField("", text: text)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .padding(.horizontal, 10)
                .frame(width: width, height: height, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 5).fill(Color.white.opacity(0.95)))
                .foregroundColor(.black)
                .font(.custom("JetBrainsMono-Regular", size: 12))
        }
    }
    
    private func labeledSecure(title: String, text: Binding<String>, width: CGFloat, height: CGFloat = 30, field: Field) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.custom("JetBrainsMono-Medium", size: 13))
                .foregroundColor(.white)
            SecureField("", text: text)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .focused($focusedField, equals: field)
                .padding(.horizontal, 10)
                .frame(width: width, height: height, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 5).fill(Color.white.opacity(0.95)))
                .foregroundColor(.black)
                .font(.custom("JetBrainsMono-Regular", size: 12))
        }
    }
}

private struct DecorativeLineDots: View {
    private let gray = Color(white: 0.40)
    private let white = Color(white: 1)
    var body: some View {
        HStack(spacing: 0) {
            Circle().fill(gray).frame(width: 6, height: 6)
            Rectangle().fill(Color.white.opacity(0.6)).frame(width: 53, height: 1)
            Circle().fill(white).frame(width: 6, height: 6)
            Rectangle().fill(Color.white.opacity(0.6)).frame(width: 53, height: 1)
            Circle().fill(gray).frame(width: 6, height: 6)
        }
        .opacity(0.9)
    }
}

private struct AppMarkImage: View {
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
    EmailJoinView()
        .preferredColorScheme(.dark)
} 
