import SwiftUI
import PhotosUI

struct ScanView: View {
    @Environment(AppState.self) private var appState

    @State private var source: PhotoSourceKind = .camera
    @State private var capturedUIImage: UIImage?
    @State private var photosPickerItem: PhotosPickerItem?
    @State private var showCamera = false
    @State private var showGalleryPicker = false
    @State private var showResult = false
    @State private var isAnalyzing = false

    private var hasPhoto: Bool { capturedUIImage != nil }

    var body: some View {
        VStack(spacing: 0) {
            ScreenHeader(title: "SCAN", subtitle: "We'll analyze your avocado photo")

            sourcePicker
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

            captureArea
                .padding(.horizontal, 20)

            Text("💡 Take a clear front-facing photo of the avocado💡")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.avocadoTextBrown)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.top, 28)
                .padding(.bottom, 12)

            if let message = appState.scanErrorMessage {
                Text(message)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.avocadoRust)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)
            }

            analyzeButton
                .padding(.horizontal, 20)
                .padding(.top, 16)

            Spacer()
        }
        .background(Color.avocadoCream)
        .photosPicker(isPresented: $showGalleryPicker, selection: $photosPickerItem, matching: .images)
        .onChange(of: photosPickerItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    capturedUIImage = uiImage
                }
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraPicker { uiImage in
                capturedUIImage = uiImage
            }
            .ignoresSafeArea()
        }
        .navigationDestination(isPresented: $showResult) {
            ResultView()
        }
    }

    private var sourcePicker: some View {
        HStack(spacing: 0) {
            sourceButton(.camera, systemImage: "camera.fill")
            sourceButton(.gallery, systemImage: "photo.on.rectangle")
        }
        .padding(1.7)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.avocadoGreen, lineWidth: 1.7)
        )
    }

    private func sourceButton(_ target: PhotoSourceKind, systemImage: String) -> some View {
        let isSelected = source == target
        return Button {
            source = target
        } label: {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                Text(target.rawValue.uppercased())
                    .tracking(2.2)
            }
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(isSelected ? Color.avocadoCream : Color.avocadoGreen)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color.avocadoGreen : Color.clear, in: RoundedRectangle(cornerRadius: 14))
        }
    }

    private var captureArea: some View {
        Button {
            switch source {
            case .camera:
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    showCamera = true
                } else {
                    source = .gallery
                }
            case .gallery:
                showGalleryPicker = true
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.avocadoTrack)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.avocadoGreen, lineWidth: 1.7))

                if let capturedUIImage {
                    Image(uiImage: capturedUIImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 270)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(Color.avocadoGreen)
                            .opacity(0.25)
                        Text("Tap to capture")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.avocadoGreen)
                    }
                    .padding(24)
                    .overlay(CornerBracketsOverlay().stroke(Color.avocadoGreen, lineWidth: 1.7))
                }
            }
            .frame(height: 270)
        }
        .buttonStyle(.plain)
    }

    private var analyzeButton: some View {
        Button {
            analyze()
        } label: {
            Text(buttonTitle)
                .font(.system(size: 14, weight: .bold))
                .tracking(2.5)
                .foregroundStyle(hasPhoto ? Color.avocadoCream : Color.avocadoTextBrown)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(hasPhoto ? Color.avocadoGreen : Color.avocadoTrack, in: RoundedRectangle(cornerRadius: 16))
        }
        .disabled(!hasPhoto || isAnalyzing)
    }

    private var buttonTitle: String {
        if isAnalyzing { return "ANALYZING…" }
        return hasPhoto ? "ANALYZE PHOTO" : "PLEASE SELECT A PHOTO FIRST"
    }

    private func analyze() {
        guard let capturedUIImage, let data = capturedUIImage.jpegData(compressionQuality: 0.85) else { return }
        Task {
            isAnalyzing = true
            let success = await appState.submitScan(imageData: data, source: source)
            isAnalyzing = false
            if success {
                showResult = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        ScanView()
    }
    .environment(AppState())
}
