import SwiftUI

// MARK: - Settings Section Header
@available(iOS 15.0, *)
struct SettingsSectionHeader: View {
    let title: String
    let icon: CinemaxIcon

    var body: some View {
        HStack(spacing: 8) {
            CinemaxIconView(icon, size: .small, color: DSColors.accentSwiftUI)
            Text(title)
                .font(DSTypography.h4SwiftUI(weight: .semibold))
                .foregroundColor(DSColors.primaryTextSwiftUI)
        }
    }
}

// MARK: - Settings Section Container
@available(iOS 15.0, *)
struct SettingsSectionContainer<Content: View>: View {
    let title: String
    let icon: CinemaxIcon
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SettingsSectionHeader(title: title, icon: icon)
            VStack(spacing: 0) {
                content()
            }
            .background(DSColors.surfaceSwiftUI)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: - Settings Toggle Row
@available(iOS 15.0, *)
struct SettingsToggleRow: View {
    let title: String
    let subtitle: String?
    @Binding var isOn: Bool
    var isEnabled: Bool = true

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(DSTypography.bodyMediumSwiftUI())
                    .foregroundColor(DSColors.primaryTextSwiftUI)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(DSTypography.bodySmallSwiftUI())
                        .foregroundColor(DSColors.secondaryTextSwiftUI)
                        .lineLimit(2)
                }
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .tint(DSColors.accentSwiftUI)
                .labelsHidden()
        }
        .padding(16)
        .contentShape(Rectangle())
        .opacity(isEnabled ? 1 : 0.5)
        .disabled(!isEnabled)
    }
}

// MARK: - Settings Navigation Row
@available(iOS 15.0, *)
struct SettingsNavigationRow: View {
    let title: String
    let value: String?
    let icon: CinemaxIcon?
    let action: () -> Void

    init(
        title: String,
        value: String? = nil,
        icon: CinemaxIcon? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.value = value
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: action) {
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

                CinemaxIconView(.arrowBack, size: .small, color: DSColors.tertiaryTextSwiftUI)
                    .rotationEffect(.degrees(180))
            }
            .padding(16)
            .frame(minHeight: 44)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Settings Info Row
@available(iOS 15.0, *)
struct SettingsInfoRow: View {
    let title: String
    let value: String
    let icon: CinemaxIcon?

    init(title: String, value: String, icon: CinemaxIcon? = nil) {
        self.title = title
        self.value = value
        self.icon = icon
    }

    var body: some View {
        HStack(spacing: 12) {
            if let icon = icon {
                CinemaxIconView(icon, size: .small, color: DSColors.secondaryTextSwiftUI)
            }

            Text(title)
                .font(DSTypography.bodyMediumSwiftUI())
                .foregroundColor(DSColors.primaryTextSwiftUI)

            Spacer()

            Text(value)
                .font(DSTypography.bodySmallSwiftUI())
                .foregroundColor(DSColors.secondaryTextSwiftUI)
        }
        .padding(16)
        .frame(minHeight: 44)
    }
}

// MARK: - Settings Button Row
@available(iOS 15.0, *)
struct SettingsButtonRow: View {
    let title: String
    let icon: CinemaxIcon?
    let isDestructive: Bool
    let action: () -> Void

    init(
        title: String,
        icon: CinemaxIcon? = nil,
        isDestructive: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isDestructive = isDestructive
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if let icon = icon {
                    CinemaxIconView(
                        icon,
                        size: .small,
                        color: isDestructive ? DSColors.errorSwiftUI : DSColors.secondaryTextSwiftUI
                    )
                }

                Text(title)
                    .font(DSTypography.bodyMediumSwiftUI())
                    .foregroundColor(isDestructive ? DSColors.errorSwiftUI : DSColors.primaryTextSwiftUI)

                Spacer()
            }
            .padding(16)
            .frame(minHeight: 44)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Settings Divider
@available(iOS 15.0, *)
struct SettingsDivider: View {
    var body: some View {
        Divider().background(DSColors.borderSwiftUI.opacity(0.3))
    }
}

// MARK: - Previews
@available(iOS 15.0, *)
struct SettingsComponentsPreview: View {
    @State private var toggleOn = true
    @State private var toggleOff = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Section Container
                SettingsSectionContainer(title: "Video Playback", icon: .film) {
                    VStack(spacing: 0) {
                        SettingsToggleRow(
                            title: "Autoplay Trailers",
                            subtitle: "Automatically play trailers",
                            isOn: $toggleOn
                        )
                        SettingsDivider()
                        SettingsNavigationRow(
                            title: "Streaming Quality",
                            value: "Auto",
                            icon: .hd
                        ) {}
                        SettingsDivider()
                        SettingsInfoRow(
                            title: "Cache Size",
                            value: "156 MB",
                            icon: .folder
                        )
                        SettingsDivider()
                        SettingsButtonRow(
                            title: "Clear Cache",
                            icon: .trashBin
                        ) {}
                    }
                }

                // Section with disabled toggle
                SettingsSectionContainer(title: "Notifications", icon: .notification) {
                    VStack(spacing: 0) {
                        SettingsToggleRow(
                            title: "Push Notifications",
                            subtitle: "Receive alerts",
                            isOn: $toggleOn
                        )
                        SettingsDivider()
                        SettingsToggleRow(
                            title: "New Releases",
                            subtitle: "Disabled when push is off",
                            isOn: $toggleOff,
                            isEnabled: false
                        )
                    }
                }

                // Destructive button
                SettingsSectionContainer(title: "Actions", icon: .settings) {
                    SettingsButtonRow(
                        title: "Sign Out",
                        icon: nil,
                        isDestructive: true
                    ) {}
                }
            }
            .padding()
            .background(DSColors.backgroundSwiftUI)
        }
    }
}

#Preview("Settings Components") {
    SettingsComponentsPreview()
}
