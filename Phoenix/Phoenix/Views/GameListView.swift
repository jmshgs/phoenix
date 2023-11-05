//
//  GameListView.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2022-12-28.
//
import SwiftUI

struct GameListView: View {
    
    @Binding var sortBy: PhoenixApp.SortBy
    @Binding var selectedGame: UUID
    @Binding var refresh: Bool
    @Binding var searchText: String
    @State private var timer: Timer?
    @State private var minWidth: CGFloat = 296
    
    @Default(.showSortByNumber) var showSortByNumber
    
    var body: some View {
        VStack {
            List(selection: $selectedGame) {
                let favoriteGames = games.filter {
                    $0.isHidden == false && ($0.name.localizedCaseInsensitiveContains(searchText) || searchText.isEmpty) && $0.isFavorite == true
                }
                if !favoriteGames.isEmpty {
                    Section(header: Text("Favorites \(showSortByNumber ? "(\(favoriteGames.count))" : "")")) {
                        ForEach(favoriteGames, id: \.id) { game in
                            GameListItem(game: game, refresh: $refresh)
                        }
                    }
                }
                switch sortBy {
                case .platform:
                    ForEach(Platform.allCases, id: \.self) { platform in
                        let gamesForPlatform = games.filter {
                            $0.platform == platform && $0.isHidden == false && ($0.name.localizedCaseInsensitiveContains(searchText) || searchText.isEmpty) && $0.isFavorite == false
                        }
                        if !gamesForPlatform.isEmpty {
                            Section(header: Text("\(platform.displayName) \(showSortByNumber ? "(\(gamesForPlatform.count))" : "")")) {
                                ForEach(gamesForPlatform, id: \.id) { game in
                                    GameListItem(game: game, refresh: $refresh)
                                }
                            }
                        }
                    }
                case .status:
                    ForEach(Status.allCases, id: \.self) { status in
                        let gamesForStatus = games.filter {
                            $0.status == status && $0.isHidden == false && ($0.name.localizedCaseInsensitiveContains(searchText) || searchText.isEmpty) && $0.isFavorite == false
                        }
                        if !gamesForStatus.isEmpty {
                            Section(header: Text("\(status.displayName) \(showSortByNumber ? "(\(gamesForStatus.count))" : "")")) {
                                ForEach(gamesForStatus, id: \.id) { game in
                                    GameListItem(game: game, refresh: $refresh)
                                }
                            }
                        }
                    }
                case .name:
                    let gamesForName = games.filter {
                        $0.isHidden == false && ($0.name.localizedCaseInsensitiveContains(searchText) || searchText.isEmpty) && $0.isFavorite == false
                    }
                    if !gamesForName.isEmpty {
                        Section(header: Text("Name")) {
                            ForEach(gamesForName, id: \.id) { game in
                                GameListItem(game: game, refresh: $refresh)
                            }
                        }
                    }
                case .recency:
                    ForEach(Recency.allCases, id: \.self) { recency in
                        let gamesForRecency = games.filter {
                            $0.recency == recency && $0.isHidden == false && ($0.name.localizedCaseInsensitiveContains(searchText) || searchText.isEmpty) && $0.isFavorite == false
                        }
                        if !gamesForRecency.isEmpty {
                            Section(header: Text("\(recency.displayName) \(showSortByNumber ? "(\(gamesForRecency.count))" : "")")) {
                                ForEach(gamesForRecency, id: \.id) { game in
                                    GameListItem(game: game, refresh: $refresh)
                                }
                            }
                        }
                    }
                }
            }
        }
        .frame(minWidth: minWidth)
        .onAppear {
        }
    }
}

struct GameListItem: View {
    @State var game: Game
    @Binding var refresh: Bool
    @State var iconSize: Double = Defaults[.listIconSize]
    @State var iconsHidden: Bool = Defaults[.listIconsHidden]
    
    var body: some View {
        HStack {
            if !iconsHidden {
                Image(nsImage: loadImageFromFile(filePath: game.icon))
                    .resizable()
                    .frame(width: iconSize, height: iconSize)
            }
            Text(game.name)
        }
        .contextMenu {
            Button(action: {
                if let idx = games.firstIndex(where: { $0.id == game.id }) {
                    games[idx].isFavorite.toggle()
                }
                saveGames()
            }) {
                Text("\(game.isFavorite ? "Unfavorite" : "Favorite") game")
            }
            .accessibility(identifier: "Favorite Game")
            Button(action: {
                if let idx = games.firstIndex(where: { $0.id == game.id }) {
                    games[idx].isHidden = true
                }
                saveGames()
            }) {
                Text("Hide game")
            }
            .accessibility(identifier: "Hide Game")
            Button(action: {
                if let idx = games.firstIndex(where: { $0.id == game.id }) {
                    games.remove(at: idx)
                }
                saveGames()
            }) {
                Text("Delete game")
            }
            .accessibility(identifier: "Delete Game")
        }
        .onChange(of: Defaults[.listIconSize]) { value in
            iconSize = value
        }
        .onChange(of: Defaults[.listIconsHidden]) { value in
            iconsHidden = value
        }
    }
}
