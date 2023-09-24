//
//  EditGameView.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2022-12-28.
//
import Foundation
import SwiftUI

struct EditGameView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    @Binding var currentGame: Game

    @State private var nameInput: String = ""
    @State private var iconOutput: String = ""
    @State private var platInput: Platform = .none
    @State private var statusInput: Status = .none
    @State private var cmdInput: String = ""
    @State private var descInput: String = ""
    @State private var headOutput: String = ""
    @State private var rateInput: String = ""
    @State private var genreInput: String = ""
    @State private var devInput: String = ""
    @State private var pubInput: String = ""
    @State private var dateInput: Date = .now
    @State private var iconIsImporting: Bool = false
    @State private var headIsImporting: Bool = false
    
    @State private var fetchMetadata = false

    var body: some View {

        ScrollView {
            VStack(alignment: .leading) {
                Group {
                    HStack {
                        Text("Name")
                            .frame(width: 70, alignment: .leading)
                        TextField("Enter game name", text: $nameInput)
                            .padding()
                            .accessibility(label: Text("NameInput"))
                    }
                    
                    HStack {
                        Text("Icon")
                            .frame(width: 70, alignment: .leading)
                            .offset(x: -15)
                        Button(
                            action: {
                                iconIsImporting = true
                            },
                            label: {
                                Text("Browse")
                            })
                        Text(iconOutput)
                    }
                    .padding()
                    .fileImporter(
                        isPresented: $iconIsImporting,
                        allowedContentTypes: [.image],
                        allowsMultipleSelection: false
                    ) { result in
                        saveIconToFile(result: result, name: nameInput) { image in
                            iconOutput = image
                        }
                    }
                    
                    
                    HStack {
                        Text("Platform")
                            .frame(width: 70, alignment: .leading)
                        Picker("", selection: $platInput) {
                            ForEach(Platform.allCases) { platform in
                                Text(platform.displayName)
                            }
                        }
                        .labelsHidden()
                        .padding()
                        .accessibility(label: Text("Platform Input"))
                    }
                    
                    HStack {
                        Text("Status")
                            .frame(width: 70, alignment: .leading)
                        Picker("", selection: $statusInput) {
                            ForEach(Status.allCases) { status in
                                Text(status.displayName)
                            }
                        }
                        .labelsHidden()
                        .padding()
                        .accessibility(label: Text("Status Input"))
                    }
                    
                    HStack {
                        Text("Command")
                            .frame(width: 70, alignment: .leading)
                        TextField("Enter terminal command to launch game", text: $cmdInput)
                            .padding()
                            .accessibility(label: Text("Command Input"))
                    }
                }
                DisclosureGroup("Metadata") {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Description")
                                .frame(width: 70, alignment: .leading)
                            TextEditor(text: $descInput)
                                .scrollContentBackground(.hidden)
                                .border(Color.gray.opacity(0.1), width: 1)
                                .background(Color.gray.opacity(0.05))
                                .frame(minHeight: 50)
                                .padding()
                                .accessibility(label: Text("Description Input"))
                        }
                        HStack {
                            Text("Genres")
                                .frame(width: 70, alignment: .leading)
                            TextEditor(text: $genreInput)
                                .scrollContentBackground(.hidden)
                                .border(Color.gray.opacity(0.1), width: 1)
                                .background(Color.gray.opacity(0.05))
                                .frame(minHeight: 50)
                                .padding()
                                .accessibility(label: Text("Genre Input"))
                        }
                        HStack {
                            Text("Header")
                                .frame(width: 70, alignment: .leading)
                                .offset(x: -15)
                            Button(
                                action: {
                                    headIsImporting = true
                                    
                                },
                                label: {
                                    Text("Browse")
                                })
                            Text(headOutput)
                        }
                        .padding()
                        .fileImporter(
                            isPresented: $headIsImporting,
                            allowedContentTypes: [.image],
                            allowsMultipleSelection: false
                        ) { result in
                            saveHeaderToFile(result: result, name: nameInput) { image in
                                headOutput = image
                            }
                        }
                        HStack {
                            Text("Rating")
                                .frame(width: 70, alignment: .leading)
                            TextField("X / 10", text: $rateInput)
                                .padding()
                                .accessibility(label: Text("Rating Input"))
                        }
                        HStack {
                            Text("Developer")
                                .frame(width: 70, alignment: .leading)
                            TextField("Enter game developer", text: $devInput)
                                .padding()
                                .accessibility(label: Text("Developer Input"))
                        }
                        HStack {
                            Text("Publisher")
                                .frame(width: 70, alignment: .leading)
                            TextField("Enter game publisher", text: $pubInput)
                                .padding()
                                .accessibility(label: Text("Publisher Input"))
                        }
                        HStack {
                            Text("Release Date")
                                .frame(width: 87, alignment: .leading)
                            DatePicker("", selection: $dateInput, in: ...Date(), displayedComponents: .date)
                                .labelsHidden()
                        }
                    }
                }
            }
            .padding()
            HStack(spacing: 20) {
                Spacer().frame(maxWidth: .infinity)
                HStack {
                    Button (
                        action: {
                            fetchMetadata = true
                        },
                        label: {
                            Text("Fetch Metadata")
                        }
                    )
                    Button(
                        action: {
                            let dateFormatter: DateFormatter = {
                                let formatter = DateFormatter()
                                formatter.dateStyle = .long
                                return formatter
                            }()
                            let dateInputStr = dateFormatter.string(from: dateInput)
                            if iconOutput == "" {
                                iconOutput = currentGame.icon
                            }
                            if headOutput == "" {
                                headOutput = currentGame.metadata["header_img"] ?? ""
                            }
                            let editedGame: Game = .init(
                                launcher: cmdInput,
                                metadata: [
                                    "description": descInput,
                                    "header_img": headOutput,
                                    "rating": rateInput,
                                    "genre": genreInput,
                                    "developer": devInput,
                                    "publisher": pubInput,
                                    "release_date": dateInputStr,
                                ],
                                icon: iconOutput,
                                name: nameInput,
                                platform: platInput,
                                status: statusInput,
                                recency: currentGame.recency,
                                is_deleted: currentGame.is_deleted,
                                is_favorite: currentGame.is_favorite
                            )
                            
                            let idx = games.firstIndex(where: { $0.name == currentGame.name })
                            games[idx!] = editedGame
                            
                            let encoder = JSONEncoder()
                            encoder.outputFormatting = .prettyPrinted
                            
                            do {
                                let gamesJSON = try JSONEncoder().encode(games)
                                
                                if var gamesJSONString = String(data: gamesJSON, encoding: .utf8) {
                                    // Add the necessary JSON elements for the string to be recognized as type "Games" on next read
                                    gamesJSONString = "{\"games\": \(gamesJSONString)}"
                                    writeGamesToJSON(data: gamesJSONString)
                                }
                            } catch {
                                logger.write(error.localizedDescription)
                            }
                            
                            if fetchMetadata {
                                FetchGameData().getGamesWithName(name: currentGame.name) {games in }
                            }
                            
                            dismiss()
                        },
                        label: {
                            Text("Save Changes")
                        }
                    )
                    .padding()
                    .frame(maxWidth: .infinity)
                }.frame(minWidth: 300)

                HStack {
                    Spacer()
                        .frame(maxWidth: .infinity)
                    Spacer()
                        .frame(maxWidth: .infinity)

                    Button (
                        action: {
                            openURL(URL(string: "https://github.com/PhoenixLauncher/Phoenix/blob/main/setup.md")!)
                        }, label: {
                            ZStack {
                                Circle()
                                    .strokeBorder(Color(NSColor.separatorColor), lineWidth: 0.5)
                                    .background(Circle().foregroundColor(Color(NSColor.controlColor)))
                                    .shadow(color: Color(NSColor.separatorColor).opacity(0.3), radius: 1)
                                    .frame(width: 20, height: 20)
                                Text("?").font(.system(size: 15, weight: .regular))
                            }
                        }
                    )
                    .buttonStyle(PlainButtonStyle())
                    .frame(maxWidth: .infinity)

                }
            }
        }
        .font(.system(size: 13))
        .frame(minWidth: 768, maxWidth: 1024, maxHeight: 2000)
        .onAppear() {
            nameInput = currentGame.name
            platInput = currentGame.platform
            statusInput = currentGame.status
            cmdInput = currentGame.launcher
            descInput = currentGame.metadata["description"] ?? ""
            genreInput = currentGame.metadata["genre"] ?? ""
            rateInput = currentGame.metadata["rating"] ?? ""
            devInput = currentGame.metadata["developer"] ?? ""
            pubInput = currentGame.metadata["publisher"] ?? ""
            // Create Date Formatter
            let dateFormatter = DateFormatter()

            // Set Date Format
            dateFormatter.dateFormat = "MMM dd, yyyy"
            // Convert String to Date
            dateInput = dateFormatter.date(from: currentGame.metadata["release_date"] ?? "") ?? Date()
        }
    }
}
