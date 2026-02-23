import SwiftUI

struct WhereToWatchSection: View {
    let watchProviders: WatchProviders?

    private var hasProviders: Bool {
        guard let providers = watchProviders else { return false }
        return !providers.flatrate.isEmpty || !providers.rent.isEmpty || !providers.buy.isEmpty
    }

    var body: some View {
        if hasProviders {
            VStack(alignment: .leading, spacing: 16) {
                Text("Where to Watch")
                    .font(DSTypography.h4SwiftUI(weight: .semibold))
                    .foregroundColor(.white)

                VStack(alignment: .leading, spacing: 12) {
                    if let flatrate = watchProviders?.flatrate, !flatrate.isEmpty {
                        providerRow(title: "Stream", providers: flatrate)
                    }
                    if let rent = watchProviders?.rent, !rent.isEmpty {
                        providerRow(title: "Rent", providers: rent)
                    }
                    if let buy = watchProviders?.buy, !buy.isEmpty {
                        providerRow(title: "Buy", providers: buy)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
        }
    }

    private func providerRow(title: String, providers: [WatchProvider]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(DSTypography.h6SwiftUI(weight: .medium))
                .foregroundColor(DSColors.secondaryTextSwiftUI)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(providers.prefix(8)) { provider in
                        ProviderLogoView(provider: provider)
                    }
                }
            }
        }
    }
}

struct ProviderLogoView: View {
    let provider: WatchProvider

    var body: some View {
        VStack(spacing: 4) {
            if let logoURL = provider.logoURL {
                AsyncImage(url: logoURL) { image in
                    image.resizable().aspectRatio(contentMode: .fit)
                } placeholder: {
                    Rectangle()
                        .fill(DSColors.surfaceSwiftUI)
                }
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Rectangle()
                    .fill(DSColors.surfaceSwiftUI)
                    .frame(width: 48, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        Text(String(provider.name.prefix(2)))
                            .font(DSTypography.h6SwiftUI(weight: .semibold))
                            .foregroundColor(.white)
                    )
            }

            Text(provider.name)
                .font(DSTypography.captionSwiftUI(weight: .regular))
                .foregroundColor(DSColors.secondaryTextSwiftUI)
                .lineLimit(1)
                .frame(width: 60)
        }
    }
}
