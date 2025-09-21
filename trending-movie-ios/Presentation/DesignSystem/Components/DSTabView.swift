import SwiftUI

@available(iOS 15.0, *)
struct DSTabView<Content: View>: View {
    let tabs: [DSTabItem]
    @Binding var selection: Int
    let content: Content


    init(tabs: [DSTabItem], selection: Binding<Int>, @ViewBuilder content: () -> Content) {
        self.tabs = tabs
        self._selection = selection
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            // Custom tab bar
            HStack(spacing: 0) {
                ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selection = index
                        }
                    } label: {
                        VStack(spacing: DSSpacing.xs) {
                            HStack(spacing: DSSpacing.xs) {
                                Image(systemName: tab.icon)
                                    .font(.body)

                                Text(tab.title)
                                    .font(DSTypography.bodyMediumSwiftUI(weight: selection == index ? .semibold : .regular))
                            }
                            .foregroundColor(selection == index ? DSColors.accentSwiftUI : DSColors.secondaryTextSwiftUI)

                            // Active indicator
                            Rectangle()
                                .fill(DSColors.accentSwiftUI)
                                .frame(height: 2)
                                .opacity(selection == index ? 1 : 0)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DSSpacing.sm)
                    }
                }
            }
            .padding(.horizontal, DSSpacing.md)
            .background(DSColors.surfaceSwiftUI)

            // Content
            content
        }
    }
}

struct DSTabItem {
    let title: String
    let icon: String

    init(title: String, icon: String) {
        self.title = title
        self.icon = icon
    }
}

@available(iOS 15.0, *)
struct DSSegmentedControl: View {
    let segments: [String]
    @Binding var selection: Int


    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(segments.enumerated()), id: \.offset) { index, segment in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selection = index
                    }
                } label: {
                    Text(segment)
                        .font(DSTypography.bodyMediumSwiftUI(weight: selection == index ? .semibold : .regular))
                        .foregroundColor(selection == index ? DSColors.accentSwiftUI : DSColors.secondaryTextSwiftUI)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DSSpacing.sm)
                        .background(
                            selection == index
                                ? DSColors.accentSwiftUI.opacity(0.1)
                                : Color.clear
                        )
                }
            }
        }
        .background(DSColors.surfaceSwiftUI)
        .cornerRadius(DSSpacing.CornerRadius.medium)
    }
}