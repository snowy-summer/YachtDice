//
//  ViewController.swift
//  YachtDice
//
//  Created by 최승범 on 5/30/24.
//

import UIKit

final class ViewController: UIViewController {
    
    @IBOutlet weak var ScoreTableView: UITableView!
    
    private var dices = [1,1,1,1,1]
    private var calculator = Calculator()

    @IBOutlet weak var DicesImage: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func rollTheDice(_ sender: UIButton) {
        
        for i in 0..<5 {
            if let randomDice = (1...6).randomElement(),
               let imageView = DicesImage.arrangedSubviews[i] as? UIImageView  {
                
                let image = Dice(rawValue: randomDice)?.image
                
                dices[i] = randomDice
                animatingImage(imageView: imageView)
                imageView.image = image
            }
        }
        
        calculator.dices = dices
    }
    
    private func animatingImage(imageView: UIImageView) {
        var diceImages = DiceImage.images
        
        diceImages.shuffle()
        imageView.animationImages = diceImages
        imageView.animationDuration = 0.3
        imageView.animationRepeatCount = 2
        imageView.startAnimating()
     }
    
}

// MARK: - configuration


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
