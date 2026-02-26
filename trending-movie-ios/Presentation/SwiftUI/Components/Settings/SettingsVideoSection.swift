import SwiftUI

// MARK: - Settings Video Section
/// Video playback settings including autoplay and quality options
@available(iOS 15.0, *)
struct SettingsVideoSection: View {
    @Binding var autoplayTrailers: Bool
    let streamingQuality: String
    let downloadQuality: String
    let onStreamingQualityTapped: () -> Void
    let onDownloadQualityTapped: () -> Void

    var body: some View {
        SettingsSectionContainer(title: "Video Playback", icon: .film) {
            VStack(spacing: 0) {
                SettingsToggleRow(
                    title: "Autoplay Trailers",
                    subtitle: "Automatically play trailers when browsing",
                    isOn: $autoplayTrailers
                )
                .accessibilityIdentifier("autoplay_trailers_toggle")

                Divider().background(DSColors.borderSwiftUI.opacity(0.3))

                SettingsNavigationRow(
                    title: "Streaming Quality",
                    value: streamingQuality,
                    icon: .hd
                ) {
                    onStreamingQualityTapped()
                }
                .accessibilityIdentifier("streaming_quality_row")

                Divider().background(DSColors.borderSwiftUI.opacity(0.3))

                SettingsNavigationRow(
                    title: "Download Quality",
                    value: downloadQuality,
                    icon: .download
                ) {
                    onDownloadQualityTapped()
                }
                .accessibilityIdentifier("download_quality_row")
            }
        }
    }
}

// MARK: - Preview
@available(iOS 15.0, *)
#Preview {
    struct PreviewWrapper: View {
        @State var autoplay = true

        var body: some View {
            SettingsVideoSection(
                autoplayTrailers: $autoplay,
                streamingQuality: "Auto",
                downloadQuality: "High",
                onStreamingQualityTapped: {},
                onDownloadQualityTapped: {}
            )
            .padding()
            .background(DSColors.backgroundSwiftUI)
        }
    }
    return PreviewWrapper()
}
