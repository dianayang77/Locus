import SwiftUI
import UIKit

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingLoginEmail: Bool = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            GridBackground()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Log in to The Grid")
                        .font(.custom("JetBrainsMono-ExtraBold", size: 22))
                        .foregroundColor(.white)
                    Spacer()
                    Text("⟨x,y,z⟩ → ∞")
                        .font(.custom("JetBrainsMono-Regular", size: 10))
                        .foregroundColor(Color(red: 0.34, green: 0.34, blue: 0.34))
                }
                .padding(.horizontal, 25)
                .padding(.top, 18)
                
                DecorativeLineDots()
                    .padding(.top, 25)
                
                // Subtitle
                Text("hey, welcome back ... choose your paths:")
                    .font(.custom("JetBrainsMono-Medium", size: 12))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.top, 40)
                    .padding(.bottom, 5)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer().frame(height: 18)
                
                // Options
                VStack(spacing: 24) {
                    authButton(title: "Continue with Apple", iconImage: Image("apple_logo")) { /* TODO: Apple sign-in */ }
                        .padding(.top, 10)
                        .padding(.bottom, 8)
                    authButton(title: "Continue with Google", iconImage: Image("google_logo"), fontSize: 10) { /* TODO: Google sign-in */ }
                        .padding(.bottom, 8)
                    authButton(title: "Continue with Outlook", iconImage: Image("outlook_logo"), fontSize: 10) { /* TODO: Outlook */ }
                        .padding(.bottom, 8)
                    
                    DividerLineDots()
                        .padding(.vertical, 4)
                    
                    authButton(title: "Continue with Email", iconImage: Image("email_logo")) { showingLoginEmail = true }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                // Back button
                Button(action: { dismiss() }) {
                    HStack {
                        Image(systemName: "arrow.left")
                        Text("back")
                            .font(.custom("JetBrainsMono-Regular", size: 13))
                    }
                    .foregroundColor(.white.opacity(0.8))
                    .frame(width: 150, height: 36)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color(red: 0.10, green: 0.10, blue: 0.10)))
                }
                .padding(.top, 28)
                
                Spacer(minLength: 12)
                
                // Footer
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
            }
        }
        .sheet(isPresented: $showingLoginEmail) {
            EmailLoginView()
                .preferredColorScheme(.dark)
        }
    }
    
    private func authButton(title: String, iconSystem: String? = nil, iconImage: Image? = nil, fontSize: CGFloat = 10, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Group {
                    if let iconImage {
                        iconImage
                            .resizable()
                            .renderingMode(.original)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 18, height: 18)
                    } else if let iconSystem {
                        Image(systemName: iconSystem)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 18, height: 18)
                            .foregroundColor(.black)
                    }
                }
                .frame(width: 24, alignment: .center)
                
                Text(title)
                    .font(.custom("JetBrainsMono-Medium", size: fontSize))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                    .allowsTightening(true)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 24, height: 18)
            }
            .padding(.horizontal, 14)
            .frame(width: 219, height: 34)
            .foregroundColor(.black.opacity(0.9))
            .background(RoundedRectangle(cornerRadius: 5).fill(Color(red: 0.86, green: 0.86, blue: 0.86)))
        }
    }
}

private struct DividerLineDots: View {
    var body: some View {
        HStack(spacing: 0) {
            Circle().fill(Color(white: 0.75)).frame(width: 6, height: 6)
            Rectangle().fill(Color.white.opacity(0.6)).frame(height: 1)
            Circle().fill(Color(white: 0.75)).frame(width: 6, height: 6)
        }
    }
}

private struct DecorativeLineDots: View {
    private let gray = Color(white: 0.40)
    private let white = Color(white: 1)
    
    var body: some View {
        HStack(spacing: 0) {
            Circle().fill(white).frame(width: 6, height: 6)
            Rectangle().fill(Color.white.opacity(0.6)).frame(width: 53, height: 1)
            Circle().fill(gray).frame(width: 6, height: 6)
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
    LoginView()
        .preferredColorScheme(.dark)
} 
