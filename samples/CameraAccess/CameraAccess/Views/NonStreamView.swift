/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the
 * LICENSE file in the root directory of this source tree.
 */

//
// NonStreamView.swift
//
// Default screen to show getting started tips after app connection
// Initiates streaming
//

import MWDATCore
import SwiftUI

struct NonStreamView: View {
  @ObservedObject var viewModel: StreamSessionViewModel
  @ObservedObject var wearablesVM: WearablesViewModel
  @ObservedObject var localization = LocalizationManager.shared
  @State private var sheetHeight: CGFloat = 300

  var body: some View {
    ZStack {
      Color.black.edgesIgnoringSafeArea(.all)

      VStack {
        HStack {
          // Language toggle on the left
          LanguageToggle()
          
          // Voice picker
          VoicePicker()
          
          Spacer()
          
          Menu {
            Button(localization.currentLanguage == .chinese ? "断开连接" : "Disconnect", role: .destructive) {
              wearablesVM.disconnectGlasses()
            }
            .disabled(wearablesVM.registrationState != .registered)
          } label: {
            Image(systemName: "gearshape")
              .resizable()
              .aspectRatio(contentMode: .fit)
              .foregroundColor(.white)
              .frame(width: 24, height: 24)
          }
        }

        Spacer()

        VStack(spacing: 12) {
          Image(.cameraAccessIcon)
            .resizable()
            .renderingMode(.template)
            .foregroundColor(.white)
            .aspectRatio(contentMode: .fit)
            .frame(width: 120)

          Text(localization.currentLanguage == .chinese ? "串流眼镜摄像头" : "Stream Your Glasses Camera")
            .font(.system(size: 20, weight: .semibold))
            .foregroundColor(.white)

          Text(localization.currentLanguage == .chinese 
               ? "点击「开始串流」按钮从眼镜传输视频，或使用相机按钮拍照。" 
               : "Tap the Start streaming button to stream video from your glasses or use the camera button to take a photo from your glasses.")
            .font(.system(size: 15))
            .multilineTextAlignment(.center)
            .foregroundColor(.white)
        }
        .padding(.horizontal, 12)

        Spacer()

        HStack(spacing: 8) {
          Image(systemName: "hourglass")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.white.opacity(0.7))
            .frame(width: 16, height: 16)

          Text(localization.currentLanguage == .chinese ? "等待设备连接..." : "Waiting for an active device")
            .font(.system(size: 14))
            .foregroundColor(.white.opacity(0.7))
        }
        .padding(.bottom, 12)
        .opacity(viewModel.hasActiveDevice ? 0 : 1)

        CustomButton(
          title: localization.startOnIPhone,
          style: .secondary,
          isDisabled: false
        ) {
          Task {
            await viewModel.handleStartIPhone()
          }
        }

        CustomButton(
          title: localization.startStreaming,
          style: .primary,
          isDisabled: !viewModel.hasActiveDevice
        ) {
          Task {
            await viewModel.handleStartStreaming()
          }
        }
      }
      .padding(.all, 24)
    }
    .sheet(isPresented: $wearablesVM.showGettingStartedSheet) {
      if #available(iOS 16.0, *) {
        GettingStartedSheetView(height: $sheetHeight)
          .presentationDetents([.height(sheetHeight)])
          .presentationDragIndicator(.visible)
      } else {
        GettingStartedSheetView(height: $sheetHeight)
      }
    }
  }
}

struct GettingStartedSheetView: View {
  @Environment(\.dismiss) var dismiss
  @Binding var height: CGFloat

  var body: some View {
    VStack(spacing: 24) {
      Text("Getting started")
        .font(.system(size: 18, weight: .semibold))
        .foregroundColor(.primary)

      VStack(spacing: 12) {
        TipItemView(
          resource: .videoIcon,
          text: "First, Camera Access needs permission to use your glasses camera."
        )
        TipItemView(
          resource: .tapIcon,
          text: "Capture photos by tapping the camera button."
        )
        TipItemView(
          resource: .smartGlassesIcon,
          text: "The capture LED lets others know when you're capturing content or going live."
        )
      }
      .padding(.bottom, 16)

      CustomButton(
        title: "Continue",
        style: .primary,
        isDisabled: false
      ) {
        dismiss()
      }
    }
    .padding(.all, 24)
    .background(
      GeometryReader { geo -> Color in
        DispatchQueue.main.async {
          height = geo.size.height
        }
        return Color.clear
      }
    )
  }
}

struct TipItemView: View {
  let resource: ImageResource
  let text: String

  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      Image(resource)
        .resizable()
        .renderingMode(.template)
        .foregroundColor(.primary)
        .aspectRatio(contentMode: .fit)
        .frame(width: 24)
        .padding(.leading, 4)
        .padding(.top, 4)

      Text(text)
        .font(.system(size: 15))
        .foregroundColor(.primary)
        .fixedSize(horizontal: false, vertical: true)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}
