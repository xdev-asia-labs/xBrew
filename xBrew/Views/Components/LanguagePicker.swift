import SwiftUI

/// Language picker menu for toolbar
struct LanguagePicker: View {
    @StateObject private var localization = LocalizationManager.shared
    
    var body: some View {
        Menu {
            ForEach(LocalizationManager.Language.allCases, id: \.self) { language in
                Button {
                    localization.currentLanguage = language
                } label: {
                    HStack {
                        Text(language.flag)
                        Text(language.displayName)
                        Spacer()
                        if localization.currentLanguage == language {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Label(localization.currentLanguage.flag, systemImage: "globe")
        }
        .labelStyle(.iconOnly)
        .help(L10n.language.localized)
    }
}
