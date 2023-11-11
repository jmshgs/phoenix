//
//  GeneralSettingsView.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2023-06-14.
//

import SwiftUI

struct GeneralSettingsView: View {
    
    @State var steamIsImporting: Bool = false
    @State var invalidFolder: Bool = false
    
    @Default(.steamFolder) var steamFolder
    
    var body: some View {
        Form {
            VStack(alignment: .leading, spacing: 15) {
                Defaults.Toggle("Detect Steam games", key: .isGameDetectionEnabled)
                HStack {
                    Text("Custom Steam folder")
                    Spacer()
                    Button(
                        action: {
                            steamIsImporting = true
                        },
                        label: {
                            Text("Browse")
                        }
                    )
                }
                .fileImporter(
                    isPresented: $steamIsImporting,
                    allowedContentTypes: [.folder],
                    allowsMultipleSelection: false
                ) { result in
                    do {
                        let selectedFolder: URL = try result.get().first ?? URL(fileURLWithPath: "")
                        if selectedFolder.lastPathComponent != "steamapps" {
                            invalidFolder = true
                        } else {
                            steamFolder = selectedFolder
                        }
                    } catch {
                        // Handle the error, e.g., print an error message or take appropriate action.
                        logger.write("Error selecting folder: \(error)")
                    }
                }
                Divider()
                Defaults.Toggle("Fetch game metadata", key: .isMetaDataFetchingEnabled)
            }
            .padding(20)
            .alert("Invalid folder", isPresented: $invalidFolder) {
                VStack {
                    Button("OK", role: .cancel) {}
                }
            } message: {
                Text("The folder path must end with 'steamapps'")
            }

        }
    }
}
