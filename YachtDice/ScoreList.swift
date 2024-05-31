//
//  ScoreList.swift
//  YachtDice
//
//  Created by 최승범 on 5/30/24.
//

import UIKit

struct Score {
    let title: String
    let image: UIImage
    
    var userScore: Int = 0
    var opponentScore: Int = 0
    
    var subtotalUserScore: String {
        "\(userScore) / 63"
    }
    
    var subtotalopponentScore: String {
        "\(opponentScore) / 63"
    }
}

struct ScoreList {
    var list = [
        Score(title: "Aces",
              image: UIImage(resource: .aces)),
        Score(title: "Deuces",
              image: UIImage(resource: .deuces)),
        Score(title: "Threes",
              image: UIImage(resource: .threes)),
        Score(title: "Fours",
              image: UIImage(resource: .fours)),
        Score(title: "Fives",
              image: UIImage(resource: .fives)),
        Score(title: "Sixes",
              image: UIImage(resource: .sixes)),
        Score(title: "Subtotal",
              image: UIImage(resource: .bonus)),
        Score(title: "Choice",
              image: UIImage(resource: .choice)),
        Score(title: "4 of a kind",
              image: UIImage(resource: .fourOfKind)),
        Score(title: "Full House",
              image: UIImage(resource: .fullHouse)),
        Score(title: "Small Straight",
              image: UIImage(resource: .smallStraight)),
        Score(title: "Large Straight",
              image: UIImage(resource: .largeStraight)),
        Score(title: "Yacht",
              image: UIImage(resource: .yacht))
    ]
    
    var subtotalUesrScore: Int {
        let subtotal = list[0...5].reduce(0) { $0 + $1.userScore }
        return subtotal
    }
    
    var totalUserScore: Int {
        var total = subtotalUesrScore + list[7...12].reduce(0) { $0 + $1.userScore }
        
        if subtotalUesrScore >= 63 { total += 35 }
        
        return total
    }
   
}

