import SwiftUI

@available(iOS 13.0, *)
struct DSCarouselSkeleton: View {
    let itemCount: Int
    let itemWidth: CGFloat
    let itemHeight: CGFloat

    init(itemCount: Int = 5, itemWidth: CGFloat = 140, itemHeight: CGFloat = 210) {
        self.itemCount = itemCount
        self.itemWidth = itemWidth
        self.itemHeight = itemHeight
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            // Header skeleton
            DSSkeletonView(width: 150, height: 24)
                .padding(.horizontal, DSSpacing.Padding.container)

            // Carousel skeleton
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DSSpacing.md) {
                    ForEach(0..<itemCount, id: \.self) { _ in
                        DSSkeletonView(
                            width: itemWidth,
                            height: itemHeight,
                            cornerRadius: DSSpacing.CornerRadius.medium
                        )
                    }
                }
                .padding(.horizontal, DSSpacing.Padding.container)
            }
        }
    }
}

@available(iOS 13.0, *)
struct DSHeroCarouselSkeleton: View {
    var body: some View {
        VStack(spacing: 0) {
            DSSkeletonView(
                width: UIScreen.main.bounds.width,
                height: UIScreen.main.bounds.height * 0.5,
                cornerRadius: 0
            )

            VStack(spacing: DSSpacing.sm) {
                DSSkeletonView(width: 250, height: 32)
                DSSkeletonView(width: 180, height: 16)

                HStack(spacing: DSSpacing.md) {
                    DSSkeletonView(width: 80, height: 36, cornerRadius: DSSpacing.CornerRadius.medium)
                    DSSkeletonView(width: 80, height: 36, cornerRadius: DSSpacing.CornerRadius.medium)
                    DSSkeletonView(width: 80, height: 36, cornerRadius: DSSpacing.CornerRadius.medium)
                    Spacer()
                }
            }
            .padding(DSSpacing.Padding.container)
        }
    }
}

@available(iOS 13.0, *)
struct DSGridSkeleton: View {
    let columns: Int
    let rows: Int

    init(columns: Int = 2, rows: Int = 3) {
        self.columns = columns
        self.rows = rows
    }

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: DSSpacing.md), count: columns), spacing: DSSpacing.md) {
            ForEach(0..<(columns * rows), id: \.self) { _ in
                DSSkeletonView(
                    width: (UIScreen.main.bounds.width - DSSpacing.Padding.container * 2 - DSSpacing.md) / CGFloat(columns),
                    height: 210,
                    cornerRadius: DSSpacing.CornerRadius.medium
                )
            }
        }
        .padding(.horizontal, DSSpacing.Padding.container)
    }
}