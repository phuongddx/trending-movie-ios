import SwiftUI

@available(iOS 15.0, *)
struct DSSearchBar: View {
    @Binding var text: String
    let placeholder: String
    let onCommit: () -> Void
    let onFilterTap: (() -> Void)?

    @FocusState private var isFocused: Bool

    init(text: Binding<String>,
         placeholder: String = "Search a title..",
         onCommit: @escaping () -> Void = {},
         onFilterTap: (() -> Void)? = nil) {
        self._text = text
        self.placeholder = placeholder
        self.onCommit = onCommit
        self.onFilterTap = onFilterTap
    }

    var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(DSColors.secondaryTextSwiftUI)
                    .font(.system(size: 16))

                TextField(placeholder, text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(DSTypography.h5SwiftUI(weight: .medium))
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
                            .font(.system(size: 14))
                    }
                }
            }
            .padding(.leading, 16)
            .padding(.trailing, onFilterTap != nil ? 8 : 16)

            if let onFilterTap = onFilterTap {
                Divider()
                    .frame(width: 1, height: 16)
                    .background(Color(hex: "#696974"))
                    .padding(.horizontal, 0)

                Button(action: onFilterTap) {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(DSColors.primaryTextSwiftUI)
                        .font(.system(size: 16))
                        .frame(width: 48, height: 48)
                }
            }
        }
        .frame(height: 48)
        .background(DSColors.surfaceSwiftUI)
        .cornerRadius(24)
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