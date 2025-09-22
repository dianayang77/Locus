import SwiftUI
import UIKit

struct JoinView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingJoinEmail: Bool = false
    @State private var alertMessage: String? = nil
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            GridBackground()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Join The Grid")
                        .font(.custom("JetBrainsMono-ExtraBold", size: 22))
                        .foregroundColor(.white)
                    Spacer()
                    Text("⟨x,y,z⟩ → ∞")
                        .font(.custom("JetBrainsMono-Regular", size: 10))
                        .foregroundColor(Color(red: 0.34, green: 0.34, blue: 0.34))
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                DecorativeLineDots()
                    .padding(.top, 30)
                
                // Subtitle
                Text("hey, glad to have you ... choose your path:")
                    .font(.custom("JetBrainsMono-Medium", size: 12))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.top, 50)
                    .padding(.bottom, 5)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer().frame(height: 18)
                
                // Options
                VStack(spacing: 24) {
                    authButton(title: "Join with Apple", iconImage: Image("apple_logo")) {
                        let manager = AppleAuthManager()
                        manager.signIn { result in
                            alertMessage = "Signed in as: \(result.userIdentifier)"
                        } onError: { error in
                            alertMessage = "Apple sign-in failed: \(error.localizedDescription)"
                        }
                    }
                        .padding(.top, 10)
                        .padding(.bottom, 8)
                    authButton(title: "Join with Google", iconImage: Image("google_logo")) {
                        let manager = GoogleAuthManager()
                        let window = UIApplication.shared.connectedScenes
                            .compactMap { $0 as? UIWindowScene }
                            .first?.windows.first { $0.isKeyWindow }
                        manager.signIn(presentingWindow: window) { result in
                            alertMessage = "Google user: \(result.email ?? result.userId)"
                        } onError: { error in
                            alertMessage = "Google sign-in failed: \(error.localizedDescription)"
                        }
                    }
                        .padding(.bottom, 8)
                    authButton(title: "Join with Outlook", iconImage: Image("outlook_logo")) { /* TODO: Outlook */ }
                        .padding(.bottom, 8)
                    
                    DividerLineDots()
                        .padding(.vertical, 4)
                    
                    authButton(title: "Join with Email", iconImage: Image("email_logo")) { showingJoinEmail = true }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                // Back button (moved up under email)
                Button(action: { dismiss() }) {
                    HStack {
                        Image(systemName: "arrow.left")
                        Text("back")
                            .font(.custom("JetBrainsMono-Medium", size: 13))
                    }
                    .foregroundColor(.white.opacity(0.8))
                    .frame(width: 150, height: 36)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color(red: 0.10, green: 0.10, blue: 0.10)))
                }
                .padding(.top, 40)
                
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
                .padding(.horizontal, 26)
                .padding(.bottom, 12)
            }
        }
        .sheet(isPresented: $showingJoinEmail) {
            EmailJoinView()
                .preferredColorScheme(.dark)
        }
        .alert(item: Binding(
            get: {
                alertMessage.map { IdentifiableString(value: $0) }
            },
            set: { newVal in alertMessage = newVal?.value }
        )) { item in
            Alert(title: Text(item.value))
        }
    }
    
    private func authButton(title: String, iconSystem: String? = nil, iconImage: Image? = nil, action: @escaping () -> Void) -> some View {
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
                
                // Centered title regardless of icon width
                Text(title)
                    .font(.custom("JetBrainsMono-Medium", size: 10))
                    .frame(maxWidth: .infinity, alignment: .center)
                
                // Invisible trailing slot to mirror icon width
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

private struct IdentifiableString: Identifiable {
    let id = UUID()
    let value: String
}

#Preview {
    JoinView()
        .preferredColorScheme(.dark)
} 
