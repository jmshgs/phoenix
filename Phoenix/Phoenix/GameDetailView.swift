//
//  GameDetailView.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2022-12-28.
//
import SwiftUI

struct GameDetailView: View {
    @State var editingGame: Bool = false
    @State var showingAlert: Bool = false
    @Binding var selectedGame: String?
    @Binding var refresh: Bool

    var body: some View {
        ScrollView {
            GeometryReader { geometry in
                if let idx = games.firstIndex(where: { $0.name == selectedGame }) {
                    let game = games[idx]

                    // create header image
                    Image(nsImage: loadImageFromFile(filePath: game.metadata["header_img"]!))
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: geometry.size.width, height: getHeightForHeaderImage(geometry)
                        )
                        .blur(radius: getBlurRadiusForImage(geometry))
                        .clipped()
                        .offset(x: 0, y: getOffsetForHeaderImage(geometry))
                }
            }.frame(height: 400)

            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        HStack(alignment: .top) {
                            // play button
                            Button(
                                action: {
                                    if let idx = games.firstIndex(where: { $0.name == selectedGame }
                                    ) {
                                        do {
                                            let game = games[idx]
                                            let currentDate = Date()
                                            // Update the last played date and write the updated information to the JSON file
                                            updateLastPlayedDate(currentDate: currentDate, games: &games)
                                            if game.launcher != "" {
                                                try shell(game)
                                            } else {
                                                showingAlert = true
                                            }
                                        } catch {
                                            logger.write("\(error)")  // handle or silence the error here
                                        }
                                    }
                                },
                                label: {
                                    Image(systemName: "play.fill")
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.white)
                                        .font(.system(size: 25))
                                    Text(" Play")
                                        .fontWeight(.medium)
                                        .foregroundColor(Color.white)
                                        .font(.system(size: 25))
                                }
                            )
                            .alert(
                                "No launcher configured. Please configure a launch command to run \(selectedGame ?? "this game")",
                                isPresented: $showingAlert
                            ) {}
                            .buttonStyle(.plain)
                            .frame(width: 175, height: 50)
                            .background(Color.accentColor)
                            .cornerRadius(10)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 5))

                            // settings button
                            Button(
                                action: {
                                    editingGame.toggle()
                                },
                                label: {
                                    Image(systemName: "gear")
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.accentColor)
                                        .font(.system(size: 27))
                                }
                            )
                            .sheet(
                                isPresented: $editingGame,
                                onDismiss: {
                                    // Refresh game list
                                    refresh.toggle()
                                },
                                content: {
                                    let idx = games.firstIndex(where: { $0.name == selectedGame })
                                    let game = games[idx!]
                                    EditGameView(currentGame: .constant(game))
                                }
                            )
                            .buttonStyle(.plain)
                            .frame(width: 50, height: 50)
                            .background(Color.accentColor.opacity(0.1))
                            .cornerRadius(10)
                        }  // hstack
                        .frame(alignment: .leading)

                        // description
                        VStack(alignment: .leading) {
                            // Game Description
                            if let idx = games.firstIndex(where: { $0.name == selectedGame }) {
                                let game = games[idx]
                                
                                Text(game.metadata["description"] ?? "No game selected")
                                    .font(.system(size: 14.5))
                                    .lineSpacing(3.5)
                                    .padding(.top, 5)
                            }
                        }
                        .frame(maxWidth: 450, alignment: .leading) // controls the width and alignment of the description text
                    }  // vstack
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(EdgeInsets(top: 10, leading: 17.5, bottom: 0, trailing: 0))

                    // Game Info
                    VStack(alignment: .trailing, spacing: 5) {
                        if let idx = games.firstIndex(where: { $0.name == selectedGame }) {
                            let game = games[idx]
                            
                            VStack(alignment: .trailing, spacing: 1) {
                                Text("Last Played")
                                    .foregroundColor(Color.white)
                                Text(game.metadata["last_played"] ?? "")
                                    .foregroundColor(Color.white.opacity(0.5))
                            }
                            VStack(alignment: .trailing, spacing: 1) {
                                Text("Platform")
                                    .foregroundColor(Color.white)
                                switch game.platform {
                                    case Platform.MAC:
                                        Text("macOS")
                                            .foregroundColor(Color.white.opacity(0.5))
                                    case Platform.STEAM:
                                        Text("Steam")
                                            .foregroundColor(Color.white.opacity(0.5))
                                    case Platform.GOG:
                                        Text("GOG")
                                            .foregroundColor(Color.white.opacity(0.5))
                                    case Platform.EPIC:
                                        Text("Epic Games")
                                            .foregroundColor(Color.white.opacity(0.5))
                                    case Platform.EMUL:
                                        Text("Emulated")
                                            .foregroundColor(Color.white.opacity(0.5))
                                    case Platform.NONE:
                                        Text("Other")
                                            .foregroundColor(Color.white.opacity(0.5))
                                }
                            }
                            VStack(alignment: .trailing, spacing: 1) {
                                Text("Rating")
                                    .foregroundColor(Color.white)
                                Text(game.metadata["rating"] ?? "")
                                    .foregroundColor(Color.white.opacity(0.5))
                            }
                            VStack(alignment: .trailing, spacing: 1) {
                                Text("Genres")
                                    .foregroundColor(Color.white)
                                Text(game.metadata["genre"] ?? "")
                                    .foregroundColor(Color.white.opacity(0.5))
                            }
                            VStack(alignment: .trailing, spacing: 1) {
                                Text("Developer")
                                    .foregroundColor(Color.white)
                                Text(game.metadata["developer"] ?? "")
                                    .foregroundColor(Color.white.opacity(0.5))
                            }
                            VStack(alignment: .trailing, spacing: 1) {
                                Text("Publisher")
                                    .foregroundColor(Color.white)
                                Text(game.metadata["publisher"] ?? "")
                                    .foregroundColor(Color.white.opacity(0.5))
                            }
                            VStack(alignment: .trailing, spacing: 1) {
                                Text("Release Date")
                                    .foregroundColor(Color.white)
                                Text(game.metadata["release_date"] ?? "")
                                    .foregroundColor(Color.white.opacity(0.5))
                            }
                        }
                    }
                    .font(.system(size: 14.5))
                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 17.5))
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .navigationTitle(selectedGame ?? "Phoenix")
    }
    
    func updateLastPlayedDate(currentDate: Date, games: inout [Game]) {
        
        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            return formatter
        }()
        
        // Convert the current date to a string using the dateFormatter
        let dateString = dateFormatter.string(from: currentDate)

        // Update the value of "last_played" in the game's metadata
        let idx = games.firstIndex(where: { $0.name == selectedGame })
        if idx != nil {
            games[idx!].metadata["last_played"] = dateString
            
            // Write the updated game information to the JSON file
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            
            do {
                let gamesJSON = try encoder.encode(GamesList(games: games))
                
                if var gamesJSONString = String(data: gamesJSON, encoding: .utf8) {
                    // Add the necessary JSON elements for the string to be recognized as type "Games" on next read
                    gamesJSONString = "{\"games\": \(gamesJSONString)}"
                    writeGamesToJSON(data: gamesJSONString)
                }
            } catch {
                logger.write(error.localizedDescription)
            }
        }
    }
}
