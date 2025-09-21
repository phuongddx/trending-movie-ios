import SwiftUI

@available(iOS 15.0, *)
struct DSSearchBar: View {
    @Binding var text: String
    let placeholder: String
    let onCommit: () -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: DSSpacing.sm) {
            HStack(spacing: DSSpacing.sm) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(DSColors.secondaryTextSwiftUI)
                    .font(.body)

                TextField(placeholder, text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(DSTypography.bodyMediumSwiftUI())
                    .foregroundColor(DSColors.primaryTextSwiftUI)
                    .focused($isFocused)
                    .onSubmit {
                        onCommit()
                    }

                if !text.isEmpty {
                    Button {
                        text = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(DSColors.secondaryTextSwiftUI)
                            .font(.body)
                    }
                }
            }
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.sm)
            .background(DSColors.surfaceSwiftUI)
            .cornerRadius(DSSpacing.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: DSSpacing.CornerRadius.medium)
                    .stroke(
                        isFocused ? DSColors.accentSwiftUI : Color.clear,
                        lineWidth: 2
                    )
            )

            if isFocused {
                Button("Cancel") {
                    text = ""
                    isFocused = false
                }
                .font(DSTypography.bodyMediumSwiftUI())
                .foregroundColor(DSColors.accentSwiftUI)
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


    var body: some View {
        VStack(spacing: 0) {
            ForEach(suggestions, id: \.self) { suggestion in
                Button {
                    onSuggestionTap(suggestion)
                } label: {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(DSColors.secondaryTextSwiftUI)
                            .font(.caption)

                        Text(suggestion)
                            .font(DSTypography.bodyMediumSwiftUI())
                            .foregroundColor(DSColors.primaryTextSwiftUI)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Image(systemName: "arrow.up.left")
                            .foregroundColor(DSColors.secondaryTextSwiftUI)
                            .font(.caption)
                    }
                    .padding(.horizontal, DSSpacing.md)
                    .padding(.vertical, DSSpacing.sm)
                }

                if suggestion != suggestions.last {
                    Divider()
                        .background(DSColors.secondaryTextSwiftUI.opacity(0.3))
                }
            }
        }
        .background(DSColors.surfaceSwiftUI)
        .cornerRadius(DSSpacing.CornerRadius.medium)
        .shadow(
            color: Color.clear,
            radius: 8,
            x: 0,
            y: 4
        )
    }
}