import SwiftUI

struct ChapterCelebration: Identifiable {
    let id = UUID()
    let finished: String
    let next: String
}

struct ChapterCompletionBanner: View {
    let celebration: ChapterCelebration

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 30, weight: .medium))
                .foregroundStyle(.green)
                .frame(width: 48, height: 48)
                .background(Color.green.opacity(0.1), in: Circle())
            VStack(alignment: .leading, spacing: 4) {
                Text("\(celebration.finished) complete")
                    .font(.subheadline.weight(.semibold))
                Text("Now reading \(celebration.next)")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(.green.opacity(0.15), lineWidth: 1))
        .shadow(color: .black.opacity(0.08), radius: 16, y: 6)
        .accessibilityElement(children: .combine)
    }
}
