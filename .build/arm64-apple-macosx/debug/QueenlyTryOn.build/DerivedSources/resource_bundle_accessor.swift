import class Foundation.Bundle

extension Foundation.Bundle {
    static let module: Bundle = {
        let mainPath = Bundle.main.bundleURL.appendingPathComponent("QueenlyTryOn_QueenlyTryOn.bundle").path
        let buildPath = "/Users/micamorales/Desktop/QueenlyTryOn/.build/arm64-apple-macosx/debug/QueenlyTryOn_QueenlyTryOn.bundle"

        let preferredBundle = Bundle(path: mainPath)

        guard let bundle = preferredBundle ?? Bundle(path: buildPath) else {
            fatalError("could not load resource bundle: from \(mainPath) or \(buildPath)")
        }

        return bundle
    }()
}