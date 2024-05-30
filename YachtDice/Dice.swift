//
//  Dice.swift
//  YachtDice
//
//  Created by 최승범 on 5/30/24.
//

import UIKit

enum Dice: Int {
    case one = 1
    case two
    case three
    case four
    case five
    case six
    
    
    var image: UIImage {
        switch self {
        case .one:
            return DiceImage.diceOne
        case .two:
            return DiceImage.diceTwo
        case .three:
            return DiceImage.diceThree
        case .four:
            return DiceImage.diceFour
        case .five:
            return DiceImage.diceFive
        case .six:
            return DiceImage.diceSix
        }
    }
}
