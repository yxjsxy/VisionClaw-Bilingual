/*
 * LanguageToggle.swift
 * VisionClaw Bilingual Edition
 *
 * A floating button to toggle between Chinese and English.
 * Created by Karl Yang / 牧牧
 */

import SwiftUI

struct LanguageToggle: View {
    @ObservedObject var localization = LocalizationManager.shared
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3)) {
                localization.toggleLanguage()
            }
        }) {
            HStack(spacing: 6) {
                Text(localization.currentLanguage.flag)
                    .font(.system(size: 20))
                Text(localization.currentLanguage.displayName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.black.opacity(0.6))
                    .overlay(
                        Capsule()
                            .strokeBorder(Color.white.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .accessibilityLabel(localization.language)
        .accessibilityHint("Tap to switch language / 点击切换语言")
    }
}

struct LanguageToggle_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray
            LanguageToggle()
        }
    }
}
