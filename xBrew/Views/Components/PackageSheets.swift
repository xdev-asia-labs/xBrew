import SwiftUI

// MARK: - Package Detail Sheet

struct PackageDetailSheet: View {
    let packageName: String
    @State private var packageInfo: PackageInfo?
    @State private var isLoading = true
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Package Details")
                    .font(.system(size: 18, weight: .semibold))
                Spacer()
                Button("Done") {
                    dismiss()
                }
            }
            .padding()
            .background(Color(nsColor: .windowBackgroundColor))
            
            Divider()
            
            // Content
            if isLoading {
                ProgressView("Loading package information...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let info = packageInfo {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Basic Info
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Basic Information")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.secondary)
                            
                            PackageDetailRow(label: "Name", value: info.name)
                            PackageDetailRow(label: "Version", value: info.version)
                            PackageDetailRow(label: "Description", value: info.description)
                            PackageDetailRow(label: "Homepage", value: info.homepage)
                        }
                        
                        // Dependencies
                        if !info.dependencies.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Dependencies")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.secondary)
                                
                                ForEach(info.dependencies, id: \.self) { dep in
                                    Text("• \(dep)")
                                        .font(.system(size: 13))
                                }
                            }
                        }
                       
                        // Caveats
                        if let caveats = info.caveats, !caveats.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("⚠️ Important Notes")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.secondary)
                                
                                Text(caveats)
                                    .font(.system(size: 12, design: .monospaced))
                                    .padding(8)
                                    .background(Color.yellow.opacity(0.1))
                                    .cornerRadius(6)
                            }
                        }
                    }
                    .padding()
                }
            } else {
                Text("Failed to load package information")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(width: 500, height: 600)
        .onAppear {
            loadPackageInfo()
        }
    }
    
    private func loadPackageInfo() {
        Task {
            packageInfo = await HomebrewManager.shared.getDetailedPackageInfo(packageName)
            isLoading = false
        }
    }
}

struct PackageDetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(label + ":")
                .font(.system(size: 13, weight: .medium))
                .frame(width: 100, alignment: .leading)
            Text(value)
                .font(.system(size: 13))
                .textSelection(.enabled)
        }
    }
}

// MARK: - Terminal Log Sheet

struct TerminalLogSheet: View {
    let output: String
    let title: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Button("Close") {
                    dismiss()
                }
            }
            .padding()
            .background(Color(nsColor: .windowBackgroundColor))
            
            Divider()
            
            // Terminal Output
            ScrollView {
                Text(output.isEmpty ? "Running..." : output)
                    .font(.system(size: 11, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .textSelection(.enabled)
            }
            .background(Color(nsColor: .textBackgroundColor))
        }
        .frame(width: 600, height: 400)
    }
}
