//
//  LocusApp.swift
//  Locus
//
//  Created by Diana Yang  on 2025-09-21.
//

import SwiftUI
#if canImport(GoogleSignIn)
import GoogleSignIn
#endif

@main
struct LocusApp: App {
    init() {
        FontRegistrar.registerBundledFonts()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    #if canImport(GoogleSignIn)
                    GIDSignIn.sharedInstance.handle(url)
                    #endif
                }
        }
    }
}
