/*
 * VoicePicker.swift
 * VisionClaw Bilingual Edition
 *
 * Voice selection UI for Gemini Live API
 * Created by Karl Yang / 牧牧
 */

import SwiftUI

struct VoicePicker: View {
    @ObservedObject var voiceManager = VoiceManager.shared
    @ObservedObject var localization = LocalizationManager.shared
    @State private var showPicker = false
    
    var body: some View {
        Button(action: {
            showPicker = true
        }) {
            HStack(spacing: 6) {
                Image(systemName: "waveform")
                    .font(.system(size: 14))
                Text(voiceManager.currentVoice.rawValue)
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.purple.opacity(0.6))
                    .overlay(
                        Capsule()
                            .strokeBorder(Color.white.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .sheet(isPresented: $showPicker) {
            VoicePickerSheet(voiceManager: voiceManager, localization: localization)
        }
    }
}

struct VoicePickerSheet: View {
    @ObservedObject var voiceManager: VoiceManager
    @ObservedObject var localization: LocalizationManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text(localization.currentLanguage == .chinese ? "推荐声音" : "Recommended")) {
                    ForEach(VoiceManager.recommended, id: \.self) { voice in
                        VoiceRow(voice: voice, isSelected: voiceManager.currentVoice == voice) {
                            voiceManager.currentVoice = voice
                            dismiss()
                        }
                    }
                }
                
                Section(header: Text(localization.currentLanguage == .chinese ? "全部声音" : "All Voices")) {
                    ForEach(GeminiVoice.allCases.filter { !VoiceManager.recommended.contains($0) }, id: \.self) { voice in
                        VoiceRow(voice: voice, isSelected: voiceManager.currentVoice == voice) {
                            voiceManager.currentVoice = voice
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle(localization.currentLanguage == .chinese ? "选择声音" : "Select Voice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(localization.currentLanguage == .chinese ? "完成" : "Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct VoiceRow: View {
    let voice: GeminiVoice
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(voice.displayName)
                        .font(.system(size: 16, weight: .medium))
                    if !voice.description.isEmpty {
                        Text(voice.description)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct VoicePicker_Previews: PreviewProvider {
    static var previews: some View {
        VoicePicker()
            .padding()
            .background(Color.black)
    }
}
