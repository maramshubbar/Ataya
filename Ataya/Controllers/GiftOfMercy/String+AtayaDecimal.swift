//
//  String+AtayaDecimal.swift
//  Ataya
//
//  Created by Fatema Maitham on 24/12/2025.
//

import Foundation
import Foundation

extension String {

    func atayaDecimal() -> Decimal? {
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return nil }

        // خلي الفاصلة مثل النقطة
        let normalized = trimmed.replacingOccurrences(of: ",", with: ".")

        // شيل أي شي مو رقم/نقطة
        let allowed = CharacterSet(charactersIn: "0123456789.")
        let cleaned = normalized.unicodeScalars.filter { allowed.contains($0) }
        let cleanedString = String(String.UnicodeScalarView(cleaned))

        if cleanedString.isEmpty { return nil }
        return Decimal(string: cleanedString)
    }
}
