import SwiftUI

/// Standard elevated card container used across Dashboard widgets and detail screens.
struct AscendCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: AscendSpacing.sm) {
            content
        }
        .padding(AscendSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AscendColor.surface, in: RoundedRectangle(cornerRadius: AscendSpacing.cardCornerRadius, style: .continuous))
    }
}

struct AscendCardHeader: View {
    let title: String
    let systemImage: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        HStack {
            Label(title, systemImage: systemImage)
                .font(AscendFont.headline())
                .foregroundStyle(AscendColor.textPrimary)
            Spacer()
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(AscendFont.footnote())
                    .foregroundStyle(AscendColor.accent)
            }
        }
    }
}
