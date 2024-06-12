//
//  File.swift
//  YachtDice
//
//  Created by 최승범 on 5/31/24.
//

import Foundation
import Combine

struct Player: Codable {
    var displayName: String
}

class GameModel: ObservableObject, Codable {
    var players = [Player]()
    @Published var playerType = PlayerType.blue

    @Published var dices = [1, 1, 1, 1, 1]
    @Published var lockedDices = [0, 0, 0, 0, 0]
    @Published var scoreList: ScoreList = ScoreList()
    @Published var opportunity: Int = 3
    @Published var totalTurn: Int = 0

    enum CodingKeys: String, CodingKey {
        case players
        case playerType
        case dices
        case lockedDices
        case scoreList
        case opportunity
        case totalTurn
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        players = try container.decode([Player].self, forKey: .players)
        playerType = try container.decode(PlayerType.self, forKey: .playerType)
        dices = try container.decode([Int].self, forKey: .dices)
        lockedDices = try container.decode([Int].self, forKey: .lockedDices)
        scoreList = try container.decode(ScoreList.self, forKey: .scoreList)
        opportunity = try container.decode(Int.self, forKey: .opportunity)
        totalTurn = try container.decode(Int.self, forKey: .totalTurn)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(players, forKey: .players)
        try container.encode(playerType, forKey: .playerType)
        try container.encode(dices, forKey: .dices)
        try container.encode(lockedDices, forKey: .lockedDices)
        try container.encode(scoreList, forKey: .scoreList)
        try container.encode(opportunity, forKey: .opportunity)
        try container.encode(totalTurn, forKey: .totalTurn)
    }
    
    init() { }
}

extension GameModel {
    func encodeToData() -> Data? {
        return try? JSONEncoder().encode(self)
    }

    static func decodeFromData(data: Data) -> GameModel? {
        return try? JSONDecoder().decode(GameModel.self, from: data)
    }
}

enum PlayerType: String, Codable {
    case red, blue
}
