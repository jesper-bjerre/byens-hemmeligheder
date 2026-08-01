import SwiftUI
import UIKit

/// Giver en formular en vej ud af tastaturet.
///
/// Beskrivelsen og de fleste andre felter er flerlinjede, så retur laver et
/// linjeskift i stedet for at lukke tastaturet. Uden dette dækker det
/// fanebladslinjen, og quizmasteren kan ikke skifte faneblad uden at lukke
/// appen.
///
/// To veje ud, fordi den ene ikke altid er der: en **Færdig**-knap over
/// tastaturet, og et træk ned i formularen.
struct DismissableKeyboard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Færdig") {
                        // `resignFirstResponder` frem for `@FocusState`: der er
                        // snesevis af felter fordelt på fem faneblade, og hver
                        // enkelt skulle ellers bære sin egen fokustilstand.
                        UIApplication.shared.sendAction(
                            #selector(UIResponder.resignFirstResponder),
                            to: nil, from: nil, for: nil)
                    }
                    .fontWeight(.semibold)
                }
            }
    }
}

extension View {
    /// Se ``DismissableKeyboard``.
    func dismissableKeyboard() -> some View { modifier(DismissableKeyboard()) }
}
