import SwiftUI

struct FullMetadataSection: View {
    let movie: Movie

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Full Details")
                .font(DSTypography.h4SwiftUI(weight: .semibold))
                .foregroundColor(.white)

            VStack(alignment: .leading, spacing: 12) {
                if let budget = movie.budget, budget > 0 {
                    MetadataRow(label: "Budget", value: formatCurrency(budget))
                }

                if let revenue = movie.revenue, revenue > 0 {
                    MetadataRow(label: "Revenue", value: formatCurrency(revenue))
                }

                if let countries = movie.productionCountries, !countries.isEmpty {
                    MetadataRow(label: "Production", value: countries.joined(separator: ", "))
                }

                if let languages = movie.spokenLanguages, !languages.isEmpty {
                    MetadataRow(label: "Languages", value: languages.prefix(5).joined(separator: ", "))
                }

                if let status = movie.status {
                    MetadataRow(label: "Status", value: status)
                }

                if let homepage = movie.homepage, !homepage.isEmpty,
                   let url = URL(string: homepage) {
                    Link(destination: url) {
                        HStack {
                            Text("Official Website")
                                .font(DSTypography.h5SwiftUI(weight: .medium))
                                .foregroundColor(Color(hex: "#12CDD9"))
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .foregroundColor(Color(hex: "#12CDD9"))
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
    }

    private func formatCurrency(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$\(value)"
    }
}

struct MetadataRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .font(DSTypography.h5SwiftUI(weight: .medium))
                .foregroundColor(DSColors.secondaryTextSwiftUI)
                .frame(width: 100, alignment: .leading)

            Text(value)
                .font(DSTypography.h5SwiftUI(weight: .regular))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
