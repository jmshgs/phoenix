//
//  GeneralSettingsView.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2023-06-14.
//

import SwiftUI

struct GeneralSettingsView: View {
    var body: some View {
        Form {
            VStack(alignment: .leading, spacing: 20) {
                Defaults.Toggle("Detect Steam games", key: .isGameDetectionEnabled)
                Defaults.Toggle("Fetch game metadata", key: .isMetaDataFetchingEnabled)
            }
        }
    }
}
