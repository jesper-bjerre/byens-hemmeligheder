import BHContracts
import BHDesignSystem
import Foundation
import SwiftUI

/// Søgning på tværs af opgavens titel, beskrivelse, emner og sted.
struct MissionSearchView: View {
    @Environment(MissionEngine.self) private var engine
    @State private var query = ""
    @State private var selectedTag: String?
    @FocusState private var searchIsFocused: Bool

    private var missions: [Mission] { engine.playableMissions }

    private var suggestedTags: [String] {
        Array(Set(missions.flatMap(\.tags)))
            .sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
            .prefix(8)
            .map { $0 }
    }

    private var results: [Mission] {
        let needle = normalized(query.trimmingCharacters(in: .whitespacesAndNewlines))
        return missions.filter { mission in
            let matchesTag = selectedTag.map { tag in
                mission.tags.contains { $0.localizedCaseInsensitiveCompare(tag) == .orderedSame }
            } ?? true
            guard matchesTag else { return false }
            guard !needle.isEmpty else { return true }

            let location = engine.location(for: mission)
            let searchable = [
                mission.title,
                mission.description,
                mission.tags.joined(separator: " "),
                location?.name ?? "",
                location?.address ?? "",
            ].joined(separator: " ")
            return normalized(searchable).contains(needle)
        }
        .sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
    }

    var body: some View {
        VStack(spacing: 0) {
            PlayerTopBar()

            ScrollView {
                LazyVStack(alignment: .leading, spacing: BHSpacing.loose) {
                    VStack(alignment: .leading, spacing: BHSpacing.tight) {
                        Text("Find en gåde")
                            .font(BHFont.title)
                            .foregroundStyle(BHColor.ink)
                            .accessibilityAddTraits(.isHeader)
                        Text("Søg efter en opgave, et historisk emne eller et sted i Vejle.")
                            .font(BHFont.body)
                            .foregroundStyle(BHColor.inkMuted)
                    }

                    searchField
                    tagFilters

                    DiscoverySectionHeader(
                        title: query.isEmpty && selectedTag == nil ? "Alle opgaver" : "Resultater",
                        subtitle: "\(results.count) \(results.count == 1 ? "opgave" : "opgaver")"
                    )

                    if results.isEmpty {
                        ContentUnavailableView(
                            "Ingen gåder fundet",
                            systemImage: "magnifyingglass",
                            description: Text("Prøv et andet sted, emne eller ord fra titlen.")
                        )
                        .frame(maxWidth: .infinity)
                    } else {
                        ForEach(results) { mission in
                            MissionDiscoveryRow(mission: mission)
                        }
                    }
                }
                .padding(BHSpacing.regular)
                .padding(.bottom, BHSpacing.section)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .background(BHColor.canvas)
        .accessibilityIdentifier("search.screen")
    }

    private var searchField: some View {
        HStack(spacing: BHSpacing.tight) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(BHColor.inkMuted)
                .accessibilityHidden(true)
            TextField("Søg efter gåder og steder", text: $query)
                .font(BHFont.body)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(false)
                .focused($searchIsFocused)
                .submitLabel(.search)
                .accessibilityIdentifier("search.field")
            if !query.isEmpty {
                Button {
                    query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(BHColor.inkMuted)
                        .frame(width: BHMetrics.minimumTapTarget, height: BHMetrics.minimumTapTarget)
                }
                .accessibilityLabel("Ryd søgning")
            }
        }
        .padding(.leading, BHSpacing.regular)
        .padding(.trailing, BHSpacing.tight)
        .frame(minHeight: BHMetrics.primaryButtonHeight)
        .background(
            RoundedRectangle(cornerRadius: BHRadius.control, style: .continuous)
                .fill(BHColor.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: BHRadius.control, style: .continuous)
                .strokeBorder(searchIsFocused ? BHColor.accent : BHColor.separator, lineWidth: 1.5)
        )
    }

    @ViewBuilder
    private var tagFilters: some View {
        if !suggestedTags.isEmpty {
            VStack(alignment: .leading, spacing: BHSpacing.tight) {
                Text("Populære emner")
                    .font(BHFont.eyebrow)
                    .foregroundStyle(BHColor.inkMuted)

                ScrollView(.horizontal) {
                    HStack(spacing: BHSpacing.tight) {
                        filterButton("Alle", tag: nil)
                        ForEach(suggestedTags, id: \.self) { tag in
                            filterButton(tag, tag: tag)
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
    }

    private func filterButton(_ title: String, tag: String?) -> some View {
        let isSelected = selectedTag == tag
        return Button {
            selectedTag = tag
        } label: {
            Text(title)
                .font(BHFont.caption)
                .foregroundStyle(isSelected ? BHColor.onAccent : BHColor.accent)
                .padding(.horizontal, BHSpacing.snug)
                .frame(minHeight: BHMetrics.minimumTapTarget)
                .background(Capsule().fill(isSelected ? BHColor.accent : BHColor.accentSoft))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func normalized(_ value: String) -> String {
        value.folding(
            options: [.diacriticInsensitive, .caseInsensitive],
            locale: Locale(identifier: "da_DK")
        )
    }
}
