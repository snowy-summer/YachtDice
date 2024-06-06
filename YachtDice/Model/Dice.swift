//
//  Dice.swift
//  YachtDice
//
//  Created by 최승범 on 5/30/24.
//

import Foundation

enum Dice: Codable {
    case one
    case two
    case three
    case four
    case five
    case six
    case bonus
    case choice
    case fourOfKind
    case fullHouse
    case smallStraight
    case largeStraight
    case yacht
    
    var scoreImageString: String {
        switch self {
        case .one:
            return "aces"
        case .two:
            return "deuces"
        case .three:
            return "threes"
        case .four:
            return "fours"
        case .five:
            return "fives"
        case .six:
            return "sixes"
        case .bonus:
            return "bonus"
        case .choice:
            return "choice"
        case .fourOfKind:
            return "fourOfKind"
        case .fullHouse:
            return "fullHouse"
        case .smallStraight:
            return "smallStraight"
        case .largeStraight:
            return "largeStraight"
        case .yacht:
            return "yacht"
        }
    }
    
    var title: String {
        switch self {
        case .one:
            return "Aces"
        case .two:
            return "Deuces"
        case .three:
            return "Threes"
        case .four:
            return "Fours"
        case .five:
            return "Fives"
        case .six:
            return "Sixes"
        case .bonus:
            return "Subtotal"
        case .choice:
            return "Choice"
        case .fourOfKind:
            return "4 of a kind"
        case .fullHouse:
            return "Full House"
        case .smallStraight:
            return "Small Straight"
        case .largeStraight:
            return "Large Straight"
        case .yacht:
            return "Yacht"
        }
    }
}
