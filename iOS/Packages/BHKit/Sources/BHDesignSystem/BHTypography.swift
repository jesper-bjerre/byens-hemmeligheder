import SwiftUI

/// Typografi bundet til Dynamic Type.
///
/// Alt er `.relativeTo` en indbygget tekststil, så teksten vokser med
/// spillerens indstilling — også hele vejen op i tilgængelighedsstørrelserne
/// (FR-037). Der er bevidst ingen faste punktstørrelser her: en fast størrelse
/// er en fast teksthøjde, og en fast teksthøjde afskærer den, der har skruet op.
public enum BHFont {
    /// Belønningsskærmens overskrift.
    public static let display = Font.system(.largeTitle, design: .serif, weight: .bold)
    /// Skærmoverskrift.
    public static let title = Font.system(.title, design: .serif, weight: .semibold)
    /// Korttitel.
    public static let heading = Font.system(.title3, design: .default, weight: .semibold)
    /// Brødtekst.
    public static let body = Font.system(.body)
    /// Fortællende tekst — lidt større, fordi den læses højt for familien.
    public static let narrative = Font.system(.body, design: .serif)
    /// `SPOR 1 AF 3` og lignende.
    public static let eyebrow = Font.system(.caption, design: .default, weight: .bold)
    public static let caption = Font.system(.caption)
    /// Talkoden. Monospaced cifre, så feltet ikke hopper under indtastning.
    public static let code = Font.system(.title, design: .monospaced, weight: .bold)
}

/// Afstande. Ét sted, så skærmene ser ud som én app.
public enum BHSpacing {
    public static let hairline: CGFloat = 2
    public static let tight: CGFloat = 8
    public static let snug: CGFloat = 12
    public static let regular: CGFloat = 16
    public static let loose: CGFloat = 24
    public static let section: CGFloat = 32
}

public enum BHRadius {
    public static let card: CGFloat = 20
    public static let control: CGFloat = 12
}

public enum BHMetrics {
    /// Apples minimum for en trykflade (FR-041).
    public static let minimumTapTarget: CGFloat = 44
    /// Primære knapper. Højere end minimum, fordi de trykkes med handsker på,
    /// i blæst, ved en havnekant.
    public static let primaryButtonHeight: CGFloat = 56
}
