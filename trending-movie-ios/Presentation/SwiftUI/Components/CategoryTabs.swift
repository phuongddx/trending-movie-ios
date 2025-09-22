import SwiftUI

struct CategoryTabs: View {
    let categories: [String]
    @Binding var selectedCategory: String

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
                        withAnimation(.easeInOut(duration: 0.2)) {
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
}

struct CategoryTab: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(DSTypography.h6SwiftUI(weight: .medium))
                .foregroundColor(isSelected ? Color(hex: "#12CDD9") : DSColors.secondaryTextSwiftUI)
                .padding(.horizontal, isSelected ? 32 : 12)
                .padding(.vertical, 8)
                .background(
                    isSelected ? DSColors.surfaceSwiftUI : Color.clear
                )
                .cornerRadius(8)
        }
    }
}