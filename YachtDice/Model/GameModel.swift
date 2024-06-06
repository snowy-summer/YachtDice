//
//  File.swift
//  YachtDice
//
//  Created by 최승범 on 5/31/24.
//

import Foundation

struct Player: Codable {
    var displayName: String
}

struct GameModel: Codable {
    var players = [Player]()
    var playerType = PlayerType.blue
    
    var dices = [1,1,1,1,1]
    var lockedDices = [0,0,0,0,0]
    var scoreList: ScoreList = ScoreList()
    
    var opportunity: Int = 3
    var totalTurn: Int = 0
    
}

extension GameModel {
    func encode() -> Data? {
        return try? JSONEncoder().encode(self)
    }
    
    static func decode(data: Data) -> GameModel? {
        return try? JSONDecoder().decode(GameModel.self, from: data)
    }
}

enum PlayerType: String, Codable {
    case red, blue
}


