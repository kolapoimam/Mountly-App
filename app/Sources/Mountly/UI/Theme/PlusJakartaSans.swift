import SwiftUI
import CoreText

/// Registers the bundled Plus Jakarta Sans static instances (generated
/// from Google Fonts' OFL-licensed variable font — see
/// `Resources/Fonts/PlusJakartaSans-OFL.txt`) for this process only, via
/// Core Text. Never installs into the user's Font Book.
enum FontRegistrar {
    private static var didRegister = false

    static func registerBundledFontsIfNeeded() {
        guard !didRegister else { return }
        didRegister = true
        guard let resourceURL = Bundle.module.resourceURL else { return }
        guard let enumerator = FileManager.default.enumerator(at: resourceURL, includingPropertiesForKeys: nil) else { return }
        for case let url as URL in enumerator where url.pathExtension.lowercased() == "ttf" {
            var errorRef: Unmanaged<CFError>?
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, &errorRef)
        }
    }
}

/// Plus Jakarta Sans at the weights Mountly bundles (Regular/Medium/
/// SemiBold/Bold/ExtraBold), scaling with Dynamic Type via `relativeTo:`.
enum PJS {
    static func regular(_ size: CGFloat, relativeTo style: Font.TextStyle = .body) -> Font {
        .custom("PlusJakartaSans-Regular", size: size, relativeTo: style)
    }
    static func medium(_ size: CGFloat, relativeTo style: Font.TextStyle = .body) -> Font {
        .custom("PlusJakartaSans-Medium", size: size, relativeTo: style)
    }
    static func semibold(_ size: CGFloat, relativeTo style: Font.TextStyle = .body) -> Font {
        .custom("PlusJakartaSans-SemiBold", size: size, relativeTo: style)
    }
    static func bold(_ size: CGFloat, relativeTo style: Font.TextStyle = .body) -> Font {
        .custom("PlusJakartaSans-Bold", size: size, relativeTo: style)
    }
    static func extraBold(_ size: CGFloat, relativeTo style: Font.TextStyle = .largeTitle) -> Font {
        .custom("PlusJakartaSans-ExtraBold", size: size, relativeTo: style)
    }
}

/// Semantic sizes matching (roughly) the system text styles they replace,
/// so existing layouts keep their proportions.
extension Font {
    static let mtLargeTitle = PJS.extraBold(28, relativeTo: .largeTitle)
    static let mtTitle = PJS.bold(22, relativeTo: .title)
    static let mtTitle2 = PJS.bold(18, relativeTo: .title2)
    static let mtTitle3 = PJS.semibold(16, relativeTo: .title3)
    static let mtHeadline = PJS.semibold(14, relativeTo: .headline)
    static let mtBody = PJS.regular(13, relativeTo: .body)
    static let mtBodyMedium = PJS.medium(13, relativeTo: .body)
    static let mtCallout = PJS.regular(12, relativeTo: .callout)
    static let mtSubheadline = PJS.medium(12, relativeTo: .subheadline)
    static let mtFootnote = PJS.regular(11, relativeTo: .footnote)
    static let mtCaption = PJS.medium(11, relativeTo: .caption)
    static let mtCaption2 = PJS.regular(10, relativeTo: .caption2)
    /// For technical/monospace-style readouts (cluster size, device ids).
    static let mtMonoCaption = Font.system(size: 11, weight: .medium, design: .monospaced)
}
