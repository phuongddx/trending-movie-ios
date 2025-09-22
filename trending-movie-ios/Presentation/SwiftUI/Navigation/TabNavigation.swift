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
        ZStack(alignment: .bottom) {
            // Main content area
            contentView
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom Cinemax tab bar
            CinemaxTabBar(selectedTab: $selectedTab)
        }
        .background(DSColors.backgroundSwiftUI)
        .environmentObject(themeManager)
    }

    @ViewBuilder
    private var contentView: some View {
        switch selectedTab {
        case 0:
            HomeView(container: container)
        case 1:
            SearchView(container: container)
        case 2:
            WatchlistView(container: container)
        case 3:
            SettingsView()
        default:
            HomeView(container: container)
        }
    }
}

// MARK: - Cinemax Tab Bar
@available(iOS 15.0, *)
struct CinemaxTabBar: View {
    @Binding var selectedTab: Int

    private let tabs = [
        TabItem(icon: .home, title: "Home", tag: 0),
        TabItem(icon: .search, title: "Search", tag: 1),
        TabItem(icon: .download, title: "Downloads", tag: 2),
        TabItem(icon: .person, title: "Profile", tag: 3)
    ]

    var body: some View {
        HStack {
            ForEach(tabs, id: \.tag) { tab in
                CinemaxTabButton(
                    tab: tab,
                    isSelected: selectedTab == tab.tag,
                    action: { selectedTab = tab.tag }
                )
                if tab.tag < tabs.count - 1 {
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 39)
        .padding(.vertical, 16)
        .background(DSColors.backgroundSwiftUI)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(DSColors.surfaceSwiftUI),
            alignment: .top
        )
    }
}

// MARK: - Tab Item Model
struct TabItem {
    let icon: CinemaxIcon
    let title: String
    let tag: Int
}

// MARK: - Cinemax Tab Button
@available(iOS 15.0, *)
struct CinemaxTabButton: View {
    let tab: TabItem
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                CinemaxIconView(
                    tab.icon,
                    size: .medium,
                    color: isSelected ? DSColors.accentSwiftUI : DSColors.secondaryTextSwiftUI
                )

                Text(tab.title)
                    .font(DSTypography.captionSwiftUI())
                    .foregroundColor(isSelected ? DSColors.accentSwiftUI : DSColors.secondaryTextSwiftUI)
            }
        }
        .frame(minWidth: 48, minHeight: 40)
    }
}

@available(iOS 15.0, *)
struct SettingsView: View {
    @StateObject private var themeManager = DSThemeManager.shared

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Profile")
                            .font(DSTypography.h3SwiftUI(weight: .semibold))
                            .foregroundColor(DSColors.primaryTextSwiftUI)

                        VStack(spacing: 0) {
                            settingsRow(title: "Account", icon: .person, hasChevron: true)
                            Divider().background(DSColors.borderSwiftUI.opacity(0.3))
                            settingsRow(title: "Preferences", icon: .settings, hasChevron: true)
                            Divider().background(DSColors.borderSwiftUI.opacity(0.3))
                            settingsRow(title: "Notifications", icon: .notification, hasChevron: true)
                        }
                        .background(DSColors.surfaceSwiftUI)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // App Info Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("About")
                            .font(DSTypography.h3SwiftUI(weight: .semibold))
                            .foregroundColor(DSColors.primaryTextSwiftUI)

                        VStack(spacing: 0) {
                            settingsRow(title: "Version", value: "1.0.0")
                            Divider().background(DSColors.borderSwiftUI.opacity(0.3))
                            settingsRow(title: "Privacy Policy", hasChevron: true)
                            Divider().background(DSColors.borderSwiftUI.opacity(0.3))
                            settingsRow(title: "Terms of Service", hasChevron: true)
                        }
                        .background(DSColors.surfaceSwiftUI)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // Actions Section
                    VStack(spacing: 12) {
                        DSActionButton(
                            title: "Clear Cache",
                            style: .secondary,
                            icon: .remove
                        ) {
                            // Implement cache clearing
                        }

                        DSActionButton(
                            title: "Sign Out",
                            style: .destructive
                        ) {
                            // Implement sign out
                        }
                    }

                    Spacer(minLength: 100) // Space for tab bar
                }
                .padding(20)
            }
            .background(DSColors.backgroundSwiftUI)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private func settingsRow(
        title: String,
        icon: CinemaxIcon? = nil,
        value: String? = nil,
        hasChevron: Bool = false
    ) -> some View {
        HStack(spacing: 12) {
            if let icon = icon {
                CinemaxIconView(icon, size: .small, color: DSColors.secondaryTextSwiftUI)
            }

            Text(title)
                .font(DSTypography.bodyMediumSwiftUI())
                .foregroundColor(DSColors.primaryTextSwiftUI)

            Spacer()

            if let value = value {
                Text(value)
                    .font(DSTypography.bodySmallSwiftUI())
                    .foregroundColor(DSColors.secondaryTextSwiftUI)
            }

            if hasChevron {
                CinemaxIconView(.arrowBack, size: .small, color: DSColors.secondaryTextSwiftUI)
                    .rotationEffect(.degrees(180))
            }
        }
        .padding(16)
        .contentShape(Rectangle())
        .onTapGesture {
            if hasChevron {
                // Handle navigation
            }
        }
    }
}