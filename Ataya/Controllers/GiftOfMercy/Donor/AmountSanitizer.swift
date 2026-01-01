//
//  AmountSanitizer.swift
//  Ataya
//
//  Created by Fatema Maitham on 01/01/2026.
//


import Foundation

enum AmountSanitizer {

    /// keeps only digits + one dot, max 2 decimals, removes negatives
    static func sanitize(_ raw: String) -> String {
        var t = raw.replacingOccurrences(of: ",", with: ".")
        t = t.replacingOccurrences(of: "-", with: "")   // ✅ remove negative sign
        t = t.filter { "0123456789.".contains($0) }

        // keep only first dot
        if let firstDot = t.firstIndex(of: ".") {
            let after = t.index(after: firstDot)
            let rest = t[after...].replacingOccurrences(of: ".", with: "")
            t = String(t[..<after]) + rest
        }

        // limit decimals to 2
        if let dot = t.firstIndex(of: ".") {
            let after = t.index(after: dot)
            let decimals = t[after...]
            if decimals.count > 2 {
                t = String(t[..<after]) + decimals.prefix(2)
            }
        }

        if t.first == "." { t = "0" + t }
        return t
    }

    static func positiveDecimal(from raw: String) -> Decimal? {
        let s = sanitize(raw)
        guard let d = Decimal(string: s), d > 0 else { return nil }
        return d
    }
}
