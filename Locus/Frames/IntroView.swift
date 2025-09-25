import SwiftUI
import UIKit

struct IntroView: View {
    @State private var currentStep = 0
    @State private var definitionOpacity = 0.0
    @State private var parametersOpacity = 0.0
    @State private var isAuthenticating = false
    @State private var showingJoin = false
    @State private var showingEmailLogin = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            GridBackground()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                TopDecorHeader()
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                
                DecorativeLineDots()
                    .padding(.top, 15)
                
                Spacer(minLength: 60)
                
                // Center headline
                VStack(spacing: 8) {
                    Text("Hey Locus, what's up?")
                        .font(.custom("JetBrainsMono-ExtraBold", size: 24))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .opacity(definitionOpacity)
                        .padding(.horizontal, 24)
                    
                    Text("...stepping into The Grid")
                        .font(.custom("JetBrainsMono-Medium", size: 18))
                        .foregroundColor(.white)
                        .opacity(definitionOpacity)
                }
                .padding(.bottom, 24)
                
                Spacer()
                
                // Auth CTAs
                VStack(spacing: 30) {
                    Button(action: { showingJoin = true }) {
                        Text("New? Join The Grid")
                            .font(.custom("JetBrainsMono-Medium", size: 15))
                            .foregroundColor(.white)
                            .frame(width: 236, height: 34)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(red: 0.10, green: 0.10, blue: 0.10)) // #1a1a19
                            )
                    }
                    .opacity(parametersOpacity)
                    
                    Button(action: { showingEmailLogin = true }) {
                        Text("or log back in")
                            .font(.custom("JetBrainsMono-Medium", size: 15))
                            .foregroundColor(Color(red: 0.23, green: 0.21, blue: 0.21)) // #3a3636
                            .frame(width: 236, height: 34)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(red: 0.86, green: 0.86, blue: 0.86)) // gainsboro
                            )
                    }
                    .opacity(parametersOpacity)
                    
                    Text("© 2025 Locus Network LLC. All rights reserved.")
                        .font(.custom("JetBrainsMono-Regular", size: 10))
                        .foregroundColor(Color(red: 0.77, green: 0.76, blue: 0.76).opacity(0.8)) // #c5c1c1
                        .padding(.top, 8)
                        .opacity(parametersOpacity)
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.6)) {
                definitionOpacity = 1.0
                parametersOpacity = 1.0
            }
        }
        .fullScreenCover(isPresented: $showingJoin) {
            JoinView()
        }
        .sheet(isPresented: $showingEmailLogin) {
            EmailLoginView()
                .preferredColorScheme(.dark)
        }
    }
    
}

// Simple app mark at top-left and formula at top-right
private struct TopDecorHeader: View {
    var body: some View {
        HStack(alignment: .center) {
            AppMarkImage()
                .frame(width: 60, height: 55)
                .opacity(0.5)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            Spacer()
            Text("⟨x,y,z⟩ → ∞")
                .font(.custom("JetBrainsMono-Medium", size: 10))
                .foregroundColor(Color(red: 0.34, green: 0.34, blue: 0.34)) // #575757
        }
    }
}

// Three dots with connecting thin lines centered below header
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

private struct AppMark: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.7), lineWidth: 1)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.clear)
                )
            // Minimal curved motif
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

// Loads PNG from Assets.xcassets named "AppMark"; falls back to vector mark if missing
private struct AppMarkImage: View {
    var body: some View {
        if let uiImage = UIImage(named: "AppMark") {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
        } else {
            AppMark()
        }
    }
}

// Locus-styled "G" with brand type (kept for potential use)
private struct LocusGLogo: View {
    let size: CGFloat
    
    var body: some View {
        Text("G")
            .font(.custom("SF Pro Display", size: size * 1.2))
            .fontWeight(.bold)
            .kerning(-1)
            .foregroundColor(.black)
            .frame(width: size, height: size)
    }
}

private struct ArcSegment: Shape {
    let start: Double
    let end: Double
    
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let radius = min(rect.width, rect.height) / 2
        p.addArc(center: CGPoint(x: rect.midX, y: rect.midY),
            radius: radius,
            startAngle: .degrees(start),
            endAngle: .degrees(end),
            clockwise: false)
        return p
    }
}

#Preview {
    IntroView()
} 
