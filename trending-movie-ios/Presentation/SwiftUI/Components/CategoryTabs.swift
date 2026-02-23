import SwiftUI

struct CategoryTabs: View {
    let categories: [String]
    @Binding var selectedCategory: String
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(categories: [String] = ["All", "Comedy", "Animation", "Documentary"],
         selectedCategory: Binding<String>) {
        self.categories = categories
        self._selectedCategory = selectedCategory
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categories, id: \.self) { category in
                    CategoryTab(
                        title: category,
                        isSelected: selectedCategory == category
                    ) {
                        triggerSelectionHaptic()
                        withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.2)) {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding(4)
            .background(DSColors.backgroundSwiftUI)
            .cornerRadius(12)
        }
    }

    private func triggerSelectionHaptic() {
        guard AppSettings.shared.isHapticEnabled else { return }
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}

struct CategoryTab: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(DSTypography.h6SwiftUI(weight: .medium))
                .foregroundColor(isSelected ? Color(hex: "#12CDD9") : DSColors.secondaryTextSwiftUI)
                .padding(.horizontal, isSelected ? 32 : 12)
                .padding(.vertical, 8)
                .frame(minHeight: TouchTarget.minimumSize)
                .background(
                    isSelected ? DSColors.surfaceSwiftUI : Color.clear
                )
                .cornerRadius(8)
                .contentShape(Rectangle())
        }
        .accessibilityLabel(title)
        .accessibilityHint(isSelected ? "Selected" : "Double tap to select")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}
