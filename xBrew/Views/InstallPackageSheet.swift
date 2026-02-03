import SwiftUI

/// Sheet for installing new packages or casks
struct InstallPackageSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var brew = HomebrewManager.shared
    
    @State private var searchText = ""
    @State private var searchResults: [SearchResult] = []
    @State private var isSearching = false
    @State private var selectedType: PackageType = .formula
    @State private var installingPackage: String?
    @State private var installOutput = ""
    @State private var showOutput = false
    @State private var errorMessage: String?
    
    enum PackageType: String, CaseIterable {
        case formula = "Formula"
        case cask = "Cask"
        
        var icon: String {
            switch self {
            case .formula: return "terminal"
            case .cask: return "app.badge"
            }
        }
    }
    
    struct SearchResult: Identifiable, Hashable {
        let id = UUID()
        let name: String
        let description: String?
        let version: String?
        let isInstalled: Bool
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            Divider()
            
            // Search & Type Picker
            searchAreaView
            
            Divider()
            
            // Content
            if showOutput {
                outputView
            } else {
                resultsView
            }
            
            Divider()
            
            // Footer
            footerView
        }
        .frame(width: 600, height: 500)
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack {
            Image(systemName: "plus.circle.fill")
                .font(.title2)
                .foregroundColor(.ds.primary)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Install Package")
                    .font(.headline)
                Text("Search and install Homebrew packages")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding()
    }
    
    // MARK: - Search Area
    
    private var searchAreaView: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Type Picker
            Picker("", selection: $selectedType) {
                ForEach(PackageType.allCases, id: \.self) { type in
                    HStack {
                        Image(systemName: type.icon)
                        Text(type.rawValue)
                    }
                    .tag(type)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 200)
            
            // Search Field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search packages...", text: $searchText)
                    .textFieldStyle(.plain)
                    .onSubmit {
                        Task { await search() }
                    }
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                        searchResults = []
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                
                if isSearching {
                    ProgressView()
                        .scaleEffect(0.7)
                }
            }
            .padding(8)
            .background(Color(nsColor: .textBackgroundColor))
            .cornerRadius(8)
        }
        .padding()
    }
    
    // MARK: - Results View
    
    private var resultsView: some View {
        Group {
            if searchResults.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(searchResults, id: \.self) { result in
                            resultRow(result)
                        }
                    }
                    .padding()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text("Search for packages")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Type a package name and press Enter to search")
                .font(.caption)
                .foregroundColor(.secondary.opacity(0.8))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func resultRow(_ result: SearchResult) -> some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: selectedType == .formula ? "terminal" : "app.badge")
                .font(.title2)
                .foregroundColor(.ds.primary)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(result.name)
                        .font(.system(size: 14, weight: .medium))
                    
                    if let version = result.version {
                        Text(version)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(4)
                    }
                    
                    if result.isInstalled {
                        Text("Installed")
                            .font(.caption2)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.ds.success)
                            .cornerRadius(4)
                    }
                }
                
                if let desc = result.description {
                    Text(desc)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            if installingPackage == result.name {
                ProgressView()
                    .scaleEffect(0.7)
            } else if !result.isInstalled {
                Button {
                    Task { await install(result.name) }
                } label: {
                    Label("Install", systemImage: "plus.circle.fill")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
        }
        .padding()
        .background(Color(nsColor: .textBackgroundColor))
        .cornerRadius(8)
    }
    
    // MARK: - Output View
    
    private var outputView: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Installing: \(installingPackage ?? "")")
                    .font(.headline)
                Spacer()
                Button("Back to Search") {
                    showOutput = false
                    installOutput = ""
                }
                .buttonStyle(.link)
            }
            .padding()
            
            ScrollViewReader { proxy in
                ScrollView {
                    Text(installOutput)
                        .font(.system(size: 12, design: .monospaced))
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .id("bottom")
                }
                .background(Color.black.opacity(0.9))
                .foregroundColor(.green)
                .onChange(of: installOutput) { _ in
                    withAnimation {
                        proxy.scrollTo("bottom", anchor: .bottom)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Footer
    
    private var footerView: some View {
        HStack {
            if let error = errorMessage {
                Label(error, systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundColor(.ds.error)
            }
            
            Spacer()
            
            Button("Cancel") {
                dismiss()
            }
            .keyboardShortcut(.cancelAction)
        }
        .padding()
    }
    
    // MARK: - Actions
    
    private func search() async {
        guard !searchText.isEmpty else { return }
        
        await MainActor.run {
            isSearching = true
            errorMessage = nil
        }
        
        let command = selectedType == .formula ? "search" : "search --cask"
        guard let output = await brew.runBrewCommand(command.split(separator: " ").map(String.init) + [searchText]) else {
            await MainActor.run {
                errorMessage = "Search failed"
                isSearching = false
            }
            return
        }
        
        // Parse results
        let lines = output.split(separator: "\n").map(String.init)
        var results: [SearchResult] = []
        
        // Get installed packages for comparison
        let installedNames = Set(selectedType == .formula ? brew.packages.map(\.name) : brew.casks.map(\.name))
        
        for line in lines {
            let name = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !name.isEmpty && !name.contains("==>") else { continue }
            
            // Get info for first few results
            var description: String? = nil
            var version: String? = nil
            
            if results.count < 10 {
                if let info = await getPackageInfo(name) {
                    description = info.description
                    version = info.version
                }
            }
            
            results.append(SearchResult(
                name: name,
                description: description,
                version: version,
                isInstalled: installedNames.contains(name)
            ))
        }
        
        await MainActor.run {
            searchResults = results
            isSearching = false
        }
    }
    
    private func getPackageInfo(_ name: String) async -> (description: String?, version: String?)? {
        let args = selectedType == .formula 
            ? ["info", "--json=v2", name]
            : ["info", "--json=v2", "--cask", name]
        
        guard let output = await brew.runBrewCommand(args),
              let data = output.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        
        if selectedType == .formula {
            if let formulae = json["formulae"] as? [[String: Any]], let formula = formulae.first {
                let desc = formula["desc"] as? String
                let version = (formula["versions"] as? [String: Any])?["stable"] as? String
                return (desc, version)
            }
        } else {
            if let casks = json["casks"] as? [[String: Any]], let cask = casks.first {
                let desc = cask["desc"] as? String
                let version = cask["version"] as? String
                return (desc, version)
            }
        }
        
        return nil
    }
    
    private func install(_ name: String) async {
        await MainActor.run {
            installingPackage = name
            showOutput = true
            installOutput = "Starting installation of \(name)...\n"
            errorMessage = nil
        }
        
        let result: (success: Bool, message: String)
        
        if selectedType == .formula {
            result = await brew.installPackage(name)
        } else {
            result = await brew.installCask(name)
        }
        
        await MainActor.run {
            installOutput += result.message + "\n"
            
            if result.success {
                installOutput += "\n✅ Installation complete!"
                // Update the search result to show as installed
                if let index = searchResults.firstIndex(where: { $0.name == name }) {
                    let old = searchResults[index]
                    searchResults[index] = SearchResult(
                        name: old.name,
                        description: old.description,
                        version: old.version,
                        isInstalled: true
                    )
                }
            } else {
                installOutput += "\n❌ Installation failed"
                errorMessage = "Installation failed"
            }
            
            installingPackage = nil
        }
    }
}

#Preview {
    InstallPackageSheet()
}
