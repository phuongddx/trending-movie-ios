import SwiftUI

// MARK: - ViewMode Enum
enum ViewMode: String, CaseIterable {
    case list = "list"
    case grid = "grid"

    var icon: String {
        switch self {
        case .list: return "list.bullet"
        case .grid: return "square.grid.2x2"
        }
    }
}

// MARK: - ViewModeToggle Component
struct ViewModeToggle: View {
    @Binding var mode: ViewMode

    var body: some View {
        Picker("", selection: $mode) {
            Image(systemName: ViewMode.list.icon)
                .tag(ViewMode.list)
                .accessibilityLabel("List view")

            Image(systemName: ViewMode.grid.icon)
                .tag(ViewMode.grid)
                .accessibilityLabel("Grid view")
        }
        .pickerStyle(.segmented)
        .frame(width: 100)
        .accessibilityLabel("View mode selector")
        .accessibilityValue("\(mode == .list ? "List" : "Grid") view selected")
    }
}

// MARK: - Preview
struct ViewModeToggle_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ViewModeToggle(mode: .constant(.list))
            ViewModeToggle(mode: .constant(.grid))
        }
        .padding()
        .background(DSColors.backgroundSwiftUI)
        .previewLayout(.sizeThatFits)
    }
}
