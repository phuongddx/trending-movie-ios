import SwiftUI

struct MovieActionButtons: View {
    let hasTrailer: Bool
    let onTrailerTap: () -> Void
    let onDownloadTap: () -> Void
    let onShareTap: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            // Trailer Button (Primary)
            Button(action: hasTrailer ? onTrailerTap : {}) {
                HStack(spacing: 8) {
                    Image(systemName: hasTrailer ? "play.fill" : "play.slash")
                        .font(.system(size: 18))
                        .foregroundColor(.white)

                    Text(hasTrailer ? "Trailer" : "No Trailer")
                        .font(DSTypography.h4SwiftUI(weight: .medium))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(hasTrailer ? Color(hex: "#12CDD9") : DSColors.surfaceSwiftUI)
                .cornerRadius(32)
            }
            .disabled(!hasTrailer)

            Spacer()

            // Download Button
            BlurButton(
                icon: "arrow.down",
                size: 48,
                iconColor: Color(hex: "#12CDD9"),
                backgroundColor: DSColors.surfaceSwiftUI
            ) {
                onDownloadTap()
            }

            // Share Button
            BlurButton(
                icon: "square.and.arrow.up",
                size: 48,
                iconColor: Color(hex: "#12CDD9"),
                backgroundColor: DSColors.surfaceSwiftUI
            ) {
                onShareTap()
            }
        }
        .padding(.horizontal, 24)
    }
}

struct MovieActionButtons_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            DSColors.backgroundSwiftUI.ignoresSafeArea()

            VStack(spacing: 20) {
                MovieActionButtons(
                    hasTrailer: true,
                    onTrailerTap: {},
                    onDownloadTap: {},
                    onShareTap: {}
                )

                MovieActionButtons(
                    hasTrailer: false,
                    onTrailerTap: {},
                    onDownloadTap: {},
                    onShareTap: {}
                )
            }
        }
    }
}