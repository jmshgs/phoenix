//
//  GameListView.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2022-12-28.
//
import SwiftUI

struct GameListView: View {
    
    @Binding var selectedGame: String?
    @Binding var refresh: Bool
    @State private var timer: Timer?
    @State private var iconSize: Double = 24
    
    var body: some View {
        List(selection: $selectedGame) {
            ForEach(Platform.allCases, id: \.self) { platform in
                let gamesForPlatform = games.filter { $0.platform == platform && $0.is_deleted == false}
                if !gamesForPlatform.isEmpty {
                    Section(header: Text(platform.displayName)) {
                        ForEach(gamesForPlatform, id: \.name) { game in
                            HStack {
                                Image(nsImage: loadImageFromFile(filePath: game.icon))
                                    .resizable()
                                    .frame(width: iconSize, height: iconSize)
                                Text(game.name)
                            }
                            .contextMenu {
                                Button(action: {
                                    deleteGame(game, refresh: $refresh)
                                }) {
                                    Text("Delete game")
                                }
                                .accessibility(identifier: "Delete Game")
                            }
                        }.scrollDisabled(true)
                    }
                }
            }
            Text(String(refresh))
                .hidden()
        }
        .onAppear {
            iconSize = UserDefaults.standard.double(forKey: "listIconSize")
            if selectedGame == nil {
                selectedGame = games[0].name
            }
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                iconSize = UserDefaults.standard.double(forKey: "listIconSize")
                refresh.toggle()
                // This code will be executed every 1 second
            }
        }
        .onDisappear {
            // Invalidate the timer when the view disappears
            timer?.invalidate()
            timer = nil
        }
    }
    
    /// Deletes a game from the games list by setting its `is_deleted` property to `true`.
    ///
    /// - Parameters:
    ///   - game: The game to delete.
    ///   - refresh: A binding to a Boolean value indicating whether the game list should be refreshed.
    func deleteGame(_ game: Game, refresh: Binding<Bool>) {
        if let index = games.firstIndex(where: { $0.name == game.name }) {
            games[index].is_deleted = true
            refresh.wrappedValue.toggle()
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted

            do {
                let gamesJSON = try encoder.encode(games)

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
