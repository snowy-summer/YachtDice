//
//  ScoreList.swift
//  YachtDice
//
//  Created by 최승범 on 5/30/24.
//

import UIKit

struct Score: Codable {
    let dice: Dice
    
    var redScore: Int = 0
    var blueScore: Int = 0
    
    var subtotalRedScore: String {
        "\(redScore) / 63"
    }
    
    var subtotalBlueScore: String {
        "\(blueScore) / 63"
    }
}

struct ScoreList: Codable {
    var list = [
        Score(dice: .one),
        Score(dice: .two),
        Score(dice: .three),
        Score(dice: .four),
        Score(dice: .five),
        Score(dice: .six),
        Score(dice: .bonus),
        Score(dice: .choice),
        Score(dice: .fourOfKind),
        Score(dice: .fullHouse),
        Score(dice: .smallStraight),
        Score(dice: .largeStraight),
        Score(dice: .yacht)
    ]
    
    var redSubtotalScore: Int {
        let subtotal = list[0...5].reduce(0) { $0 + $1.redScore }
        return subtotal
    }
    
    var redTotalScore: Int {
        var total = redSubtotalScore + list[7...12].reduce(0) { $0 + $1.redScore }
        
        if redSubtotalScore >= 63 { total += 35 }
        
        return total
    }
    
    var blueSubtotalScore: Int {
        let subtotal = list[0...5].reduce(0) { $0 + $1.blueScore }
        return subtotal
    }
    
    var blueTotalScore: Int {
        var total = blueSubtotalScore + list[7...12].reduce(0) { $0 + $1.blueScore }
        
        if blueSubtotalScore >= 63 { total += 35 }
        
        return total
    }
   
}

