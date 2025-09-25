import SwiftUI
import UIKit

struct EmailLoginView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isKeyboardVisible = false
    
    var body: some View {
        ZStack {
            GridBackground()
                .ignoresSafeArea()
            content
        }
    }
    
    @ViewBuilder
    private var content: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Log in with Username")
                    .font(.custom("JetBrainsMono-ExtraBold", size: 18))
                    .foregroundColor(.white)
                Spacer()
                Text("(x,y,z) → ∞")
                    .font(.custom("JetBrainsMono-Regular", size: 10))
                    .foregroundColor(Color(red: 0.34, green: 0.34, blue: 0.34))
            }
            .padding(.horizontal, 25)
            .padding(.top, 18)
            
            DecorativeLineDots()
                .padding(.top, 25)
            
            // Subtitle
            Text("hey, let’s take you back to The Grid:")
                .font(.custom("JetBrainsMono-Medium", size: 12))
                .foregroundColor(.white.opacity(0.8))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 18)
                .padding(.top, 40)
            
            // Username field
            VStack(alignment: .leading, spacing: 8) {
                Text("Enter username:")
                    .font(.custom("JetBrainsMono-Medium", size: 13))
                    .foregroundColor(.white)
                TextField("username", text: $username)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .padding(.horizontal, 10)
                    .frame(height: 25)
                    .background(RoundedRectangle(cornerRadius: 5).fill(Color(white: 1)))
                    .foregroundColor(.black)
                    .font(.custom("JetBrainsMono-Regular", size: 12))
            }
            .padding(.horizontal, 18)
            .padding(.top, 30)
            
            // Password field
            VStack(alignment: .leading, spacing: 8) {
                Text("Enter password:")
                    .font(.custom("JetBrainsMono-Medium", size: 13))
                    .foregroundColor(.white)
                SecureField("••••••••", text: $password)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .padding(.horizontal, 10)
                    .frame(height: 25)
                    .background(RoundedRectangle(cornerRadius: 5).fill(Color(white: 1)))
                    .foregroundColor(.black)
                    .font(.custom("JetBrainsMono-Regular", size: 12))
                Text("forgot password")
                    .font(.custom("JetBrainsMono-Medium", size: 10))
                    .foregroundColor(.white.opacity(0.8))
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.horizontal, 18)
            .padding(.top, 30)
            
            Spacer()
            
            // Back / Continue
            HStack(spacing: 24) {
                Button(action: { dismiss() }) {
                    HStack {
                        Image(systemName: "arrow.left")
                        Text("back")
                            .font(.custom("JetBrainsMono-Regular", size: 13))
                    }
                    .foregroundColor(.white.opacity(0.85))
                    .frame(width: 150, height: 36)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color(red: 0.10, green: 0.10, blue: 0.10)))
                }
                
                Button(action: { /* TODO: handle username login */ }) {
                    HStack {
                        Text("continue")
                            .font(.custom("JetBrainsMono-Medium", size: 12))
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.black)
                    .frame(width: 150, height: 36)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color(white: 0.9)))
                }
            }
            .padding(.top, 12)
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
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
                .background(Color.black)
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
}
    
#Preview {
    EmailLoginView()
        .preferredColorScheme(.dark)
}
