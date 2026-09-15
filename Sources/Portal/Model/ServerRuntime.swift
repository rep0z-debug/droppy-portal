import Foundation

enum ServerRuntime {
    static func label(forProcessNamed name: String) -> String? {
        catalogue[simplified(name)]
    }

    static func isDevelopmentPort(_ port: UInt16) -> Bool {
        if favouritePorts.contains(port) { return true }
        return favouriteRanges.contains { $0.contains(port) }
    }

    static func isSystemBinary(at path: String) -> Bool {
        systemLocations.contains { path.hasPrefix($0) }
    }

    private static func simplified(_ name: String) -> String {
        var trimmed = Substring(name.lowercased())
        while let last = trimmed.last, last.isNumber || last == "." {
            trimmed = trimmed.dropLast()
        }
        return trimmed.isEmpty ? name.lowercased() : String(trimmed)
    }

    private static let catalogue: [String: String] = [
        "node": "Node",
        "deno": "Deno",
        "bun": "Bun",
        "vite": "Vite",
        "next": "Next.js",
        "next-server": "Next.js",
        "nuxt": "Nuxt",
        "astro": "Astro",
        "remix": "Remix",
        "ng": "Angular",
        "npm": "npm",
        "npx": "npm",
        "pnpm": "pnpm",
        "yarn": "Yarn",
        "webpack": "Webpack",
        "esbuild": "esbuild",
        "rollup": "Rollup",
        "parcel": "Parcel",
        "serve": "serve",
        "live-server": "live-server",
        "http-server": "http-server",
        "python": "Python",
        "flask": "Flask",
        "gunicorn": "Gunicorn",
        "uvicorn": "Uvicorn",
        "hypercorn": "Hypercorn",
        "streamlit": "Streamlit",
        "jupyter": "Jupyter",
        "jupyter-lab": "Jupyter",
        "jupyter-notebook": "Jupyter",
        "ruby": "Ruby",
        "rails": "Rails",
        "puma": "Puma",
        "rackup": "Rack",
        "jekyll": "Jekyll",
        "php": "PHP",
        "php-fpm": "PHP",
        "java": "Java",
        "gradle": "Gradle",
        "mvn": "Maven",
        "dotnet": "dotnet",
        "cargo": "Cargo",
        "trunk": "Trunk",
        "go": "Go",
        "air": "Air",
        "hugo": "Hugo",
        "caddy": "Caddy",
        "nginx": "nginx",
        "mix": "Elixir",
        "beam": "Elixir",
        "com.docker.backend": "Docker"
    ]

    private static let favouritePorts: Set<UInt16> = [1313, 1337, 3333, 4000, 4200, 4321, 5555, 6006, 8888, 9000, 9090]

    private static let favouriteRanges: [ClosedRange<UInt16>] = [
        3000...3010,
        5000...5010,
        5173...5180,
        8000...8010,
        8080...8090
    ]

    private static let systemLocations = ["/System/", "/usr/libexec/", "/Library/Apple/"]
}
