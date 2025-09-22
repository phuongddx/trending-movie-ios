import SwiftUI

struct MovieActionButtons: View {
    let onTrailerTap: () -> Void
    let onDownloadTap: () -> Void
    let onShareTap: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            // Trailer Button (Primary)
            Button(action: onTrailerTap) {
                HStack(spacing: 8) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white)

                    Text("Trailer")
                        .font(DSTypography.h4SwiftUI(weight: .medium))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color(hex: "#12CDD9"))
                .cornerRadius(32)
            }

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

            MovieActionButtons(
                onTrailerTap: {},
                onDownloadTap: {},
                onShareTap: {}
            )
        }
    }
}