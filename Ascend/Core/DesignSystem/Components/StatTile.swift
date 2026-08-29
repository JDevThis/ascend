import SwiftUI

struct StatTile: View {
    let title: String
    let value: String
    var systemImage: String? = nil
    var tint: Color = AscendColor.accent

    var body: some View {
        VStack(alignment: .leading, spacing: AscendSpacing.xxs) {
            if let systemImage {
                Image(systemName: systemImage)
                    .foregroundStyle(tint)
                    .font(.system(size: 18, weight: .semibold))
            }
            Text(value)
                .font(AscendFont.title())
                .foregroundStyle(AscendColor.textPrimary)
            Text(title)
                .font(AscendFont.caption())
                .foregroundStyle(AscendColor.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AscendSpacing.md)
        .background(AscendColor.surfaceSecondary, in: RoundedRectangle(cornerRadius: AscendSpacing.controlCornerRadius, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

struct EmptyStateView: View {
    let systemImage: String
    let title: String
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: AscendSpacing.sm) {
            Image(systemName: systemImage)
                .font(.system(size: 40))
                .foregroundStyle(AscendColor.textSecondary)
            Text(title)
                .font(AscendFont.headline())
                .foregroundStyle(AscendColor.textPrimary)
            Text(message)
                .font(AscendFont.subheadline())
                .foregroundStyle(AscendColor.textSecondary)
                .multilineTextAlignment(.center)
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
                    .tint(AscendColor.accent)
                    .padding(.top, AscendSpacing.xs)
            }
        }
        .padding(AscendSpacing.xl)
        .frame(maxWidth: .infinity)
    }
}
