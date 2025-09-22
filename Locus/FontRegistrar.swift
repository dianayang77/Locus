import SwiftUI
import CoreText
import UIKit

/// Registers all bundled fonts so `.custom(_, size:)` works without Info.plist entries.
enum FontRegistrar {
    static func registerBundledFonts() {
        // Collect all ttf/otf URLs in the app bundle (handles flattened resources)
        let ttfUrls = Bundle.main.urls(forResourcesWithExtension: "ttf", subdirectory: nil) ?? []
        let otfUrls = Bundle.main.urls(forResourcesWithExtension: "otf", subdirectory: nil) ?? []
        let all = ttfUrls + otfUrls

        for url in all {
            registerFont(at: url)
        }

        #if DEBUG
        verifyInstalledFontNames(["JetBrainsMono-ExtraBold", "JetBrainsMono-Medium", "JetBrainsMono-Regular"])
        #endif
    }

    private static func registerFont(at url: URL) {
        guard let dataProvider = CGDataProvider(url: url as CFURL),
              let cgFont = CGFont(dataProvider) else { return }
        var errorRef: Unmanaged<CFError>?
        CTFontManagerRegisterGraphicsFont(cgFont, &errorRef)
    }

    private static func verifyInstalledFontNames(_ names: [String]) {
        for name in names {
            if UIFont(name: name, size: 12) == nil {
                print("[FontRegistrar] Warning: Font not available — \(name)")
            }
        }
    }
} 