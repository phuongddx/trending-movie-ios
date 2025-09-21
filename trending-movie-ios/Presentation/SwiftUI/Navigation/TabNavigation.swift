import SwiftUI

@available(iOS 15.0, *)
struct TabNavigationView: View {
    private let container: AppContainer
    @State private var selectedTab = 0
    @StateObject private var themeManager = DSThemeManager.shared

    init(container: AppContainer) {
        self.container = container
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            HomeView(container: container)
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                    Text("Home")
                }
                .tag(0)

            // Search Tab
            SearchView(container: container)
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "magnifyingglass.circle.fill" : "magnifyingglass")
                    Text("Search")
                }
                .tag(1)

            // Watchlist Tab
            WatchlistView(container: container)
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "bookmark.fill" : "bookmark")
                    Text("Watchlist")
                }
                .tag(2)

            // Settings/Profile Tab
            SettingsView()
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "person.fill" : "person")
                    Text("Profile")
                }
                .tag(3)
        }
        .accentColor(DSColors.accentSwiftUI(for: themeManager.currentTheme))
        .environment(\.dsTheme, themeManager.currentTheme)
        .environmentObject(themeManager)
    }
}

@available(iOS 15.0, *)
struct SettingsView: View {
    @StateObject private var themeManager = DSThemeManager.shared
    @Environment(\.dsTheme) private var theme

    var body: some View {
        NavigationView {
            VStack(spacing: DSSpacing.lg) {
                VStack(spacing: DSSpacing.md) {
                    // Theme Section
                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                        Text("Appearance")
                            .font(DSTypography.title3SwiftUI(weight: .semibold))
                            .foregroundColor(DSColors.primaryTextSwiftUI(for: theme))

                        HStack {
                            Text("Theme")
                                .font(DSTypography.bodySwiftUI())
                                .foregroundColor(DSColors.primaryTextSwiftUI(for: theme))

                            Spacer()

                            Button {
                                themeManager.toggleTheme()
                            } label: {
                                HStack(spacing: DSSpacing.xs) {
                                    Image(systemName: theme == .dark ? "moon.fill" : "sun.max.fill")
                                    Text(theme == .dark ? "Dark" : "Light")
                                }
                                .font(DSTypography.subheadlineSwiftUI(weight: .medium))
                                .foregroundColor(DSColors.accentSwiftUI(for: theme))
                            }
                        }
                        .padding(DSSpacing.md)
                        .background(DSColors.secondaryBackgroundSwiftUI(for: theme))
                        .cornerRadius(DSSpacing.CornerRadius.medium)
                    }

                    // App Info Section
                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                        Text("About")
                            .font(DSTypography.title3SwiftUI(weight: .semibold))
                            .foregroundColor(DSColors.primaryTextSwiftUI(for: theme))

                        VStack(spacing: 0) {
                            settingsRow(title: "Version", value: "1.0.0")
                            Divider()
                                .background(DSColors.secondaryTextSwiftUI(for: theme).opacity(0.3))
                            settingsRow(title: "Privacy Policy", value: nil, hasChevron: true)
                            Divider()
                                .background(DSColors.secondaryTextSwiftUI(for: theme).opacity(0.3))
                            settingsRow(title: "Terms of Service", value: nil, hasChevron: true)
                        }
                        .background(DSColors.secondaryBackgroundSwiftUI(for: theme))
                        .cornerRadius(DSSpacing.CornerRadius.medium)
                    }
                }

                Spacer()

                // Clear Cache Button
                DSActionButton(title: "Clear Cache", style: .secondary) {
                    // Implement cache clearing
                }
            }
            .padding(DSSpacing.Padding.container)
            .background(DSColors.primaryBackgroundSwiftUI(for: theme))
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private func settingsRow(title: String, value: String?, hasChevron: Bool = false) -> some View {
        HStack {
            Text(title)
                .font(DSTypography.bodySwiftUI())
                .foregroundColor(DSColors.primaryTextSwiftUI(for: theme))

            Spacer()

            if let value = value {
                Text(value)
                    .font(DSTypography.subheadlineSwiftUI())
                    .foregroundColor(DSColors.secondaryTextSwiftUI(for: theme))
            }

            if hasChevron {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(DSColors.secondaryTextSwiftUI(for: theme))
            }
        }
        .padding(DSSpacing.md)
        .contentShape(Rectangle())
        .onTapGesture {
            if hasChevron {
                // Handle navigation
            }
        }
    }
}