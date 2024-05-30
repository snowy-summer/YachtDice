//
//  DiceImage.swift
//  YachtDice
//
//  Created by 최승범 on 5/30/24.
//

import UIKit

struct DiceImage {
    static let images = [
        diceOne,
        diceTwo,
        diceThree,
        diceFour,
        diceFive,
        diceSix
    ]
    
    static let diceOne = UIImage(resource: .diceOne)
    static let diceTwo = UIImage(resource: .diceTwo)
    static let diceThree = UIImage(resource: .diceThree)
    static let diceFour = UIImage(resource: .diceFour)
    static let diceFive = UIImage(resource: .diceFive)
    static let diceSix = UIImage(resource: .diceSix)
}
