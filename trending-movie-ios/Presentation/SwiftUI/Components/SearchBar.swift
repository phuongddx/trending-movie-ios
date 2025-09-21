import SwiftUI

@available(iOS 15.0, *)
struct DSSearchBar: View {
    @Binding var text: String
    let placeholder: String
    let onCommit: () -> Void

    @Environment(\.dsTheme) private var theme
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: DSSpacing.sm) {
            HStack(spacing: DSSpacing.sm) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(DSColors.secondaryTextSwiftUI(for: theme))
                    .font(.body)

                TextField(placeholder, text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(DSTypography.bodySwiftUI())
                    .foregroundColor(DSColors.primaryTextSwiftUI(for: theme))
                    .focused($isFocused)
                    .onSubmit {
                        onCommit()
                    }

                if !text.isEmpty {
                    Button {
                        text = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(DSColors.secondaryTextSwiftUI(for: theme))
                            .font(.body)
                    }
                }
            }
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.sm)
            .background(DSColors.secondaryBackgroundSwiftUI(for: theme))
            .cornerRadius(DSSpacing.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: DSSpacing.CornerRadius.medium)
                    .stroke(
                        isFocused ? DSColors.accentSwiftUI(for: theme) : Color.clear,
                        lineWidth: 2
                    )
            )

            if isFocused {
                Button("Cancel") {
                    text = ""
                    isFocused = false
                }
                .font(DSTypography.bodySwiftUI())
                .foregroundColor(DSColors.accentSwiftUI(for: theme))
                .transition(.move(edge: .trailing))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

@available(iOS 15.0, *)
struct SearchSuggestionsList: View {
    let suggestions: [String]
    let onSuggestionTap: (String) -> Void

    @Environment(\.dsTheme) private var theme

    var body: some View {
        VStack(spacing: 0) {
            ForEach(suggestions, id: \.self) { suggestion in
                Button {
                    onSuggestionTap(suggestion)
                } label: {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(DSColors.secondaryTextSwiftUI(for: theme))
                            .font(.caption)

                        Text(suggestion)
                            .font(DSTypography.bodySwiftUI())
                            .foregroundColor(DSColors.primaryTextSwiftUI(for: theme))
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Image(systemName: "arrow.up.left")
                            .foregroundColor(DSColors.secondaryTextSwiftUI(for: theme))
                            .font(.caption)
                    }
                    .padding(.horizontal, DSSpacing.md)
                    .padding(.vertical, DSSpacing.sm)
                }

                if suggestion != suggestions.last {
                    Divider()
                        .background(DSColors.secondaryTextSwiftUI(for: theme).opacity(0.3))
                }
            }
        }
        .background(DSColors.secondaryBackgroundSwiftUI(for: theme))
        .cornerRadius(DSSpacing.CornerRadius.medium)
        .shadow(
            color: theme == .dark ? Color.clear : Color.black.opacity(0.1),
            radius: 8,
            x: 0,
            y: 4
        )
    }
}