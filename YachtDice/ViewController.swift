//
//  ViewController.swift
//  YachtDice
//
//  Created by 최승범 on 5/30/24.
//

import UIKit

final class ViewController: UIViewController {
    
    @IBOutlet weak var scoreTableView: UITableView!
    @IBOutlet weak var dicesImageStackView: UIStackView!
    @IBOutlet weak var lockedDiceImageStackView: UIStackView!
    @IBOutlet weak var userTotalScoreLabel: UILabel!
    @IBOutlet weak var opponentTotalScoreLabel: UILabel!
    @IBOutlet weak var opportunityView: UIView!
    @IBOutlet weak var opportunityLabel: UILabel!
    
    private var dices = [1,1,1,1,1] {
        didSet {
            calculator.dices = dices
        }
    }
    private var lockedDices = [0,0,0,0,0]
    private var calculator = Calculator()
    
    private var scoreList = ScoreList() {
        didSet {
            scoreTableView.reloadData()
        }
    }
    
    private var rule = Rule() {
        didSet {
            opportunityLabel.text = "\(rule.opportunity)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        configureOpportunityView()
    }
    
    @IBAction func lockDice(_ sender: UITapGestureRecognizer) {
        if let imageView = sender.view as? UIImageView,
           let  lockedImageView = lockedDiceImageStackView.arrangedSubviews[imageView.tag] as? UIImageView {
            
            if dices[imageView.tag] == 0 { return }
            
            lockedImageView.image = Dice(rawValue: dices[imageView.tag])?.image
            imageView.image = nil
            
            lockedDices[imageView.tag] = dices[imageView.tag]
            dices[imageView.tag] = 0
        }
        
    }
    
    @IBAction func unlockDice(_ sender: UITapGestureRecognizer) {
        if let imageView = sender.view as? UIImageView,
           let  diceImageView = dicesImageStackView.arrangedSubviews[imageView.tag] as? UIImageView {
            
            if lockedDices[imageView.tag] == 0 { return }
            
            diceImageView.image = Dice(rawValue: lockedDices[imageView.tag])?.image
            imageView.image = nil
            
            dices[imageView.tag] = lockedDices[imageView.tag]
            lockedDices[imageView.tag] = 0
            
        }
        
    }
    
    
    @IBAction func rollTheDice(_ sender: UIButton) {
        
        if rule.opportunity == 0 {
            return
        }
        
        rule.opportunity -= 1
        
        for i in 0..<5 {
            if let randomDice = (1...6).randomElement(),
               let imageView = dicesImageStackView.arrangedSubviews[i] as? UIImageView  {
                
                let image = Dice(rawValue: randomDice)?.image
                
                if dices[i] != 0 {
                    dices[i] = randomDice
                    animatingImage(imageView: imageView)
                    imageView.image = image
                }
                
            }
        }
        
        
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

//MARK: -  TableView Delegate, DataSource

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scoreList.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ScoreTableViewCell.identifier) as? ScoreTableViewCell else { return ScoreTableViewCell() }
        
        
        cell.updateContent(data: scoreList.list[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        
        resetDiceImage()
        
        switch indexPath.row {
        case 0...5:
            scoreList.list[indexPath.row].userScore = calculator.countOfDice(num: indexPath.row + 1)
            scoreList.list[6].userScore = scoreList.uesrSubtotalScore
        case 7:
            scoreList.list[indexPath.row].userScore = calculator.choice
        case 8:
            scoreList.list[indexPath.row].userScore = calculator.fourOfKind
        case 9:
            scoreList.list[indexPath.row].userScore = calculator.fullHouse
        case 10:
            scoreList.list[indexPath.row].userScore = calculator.smallStraight
        case 11:
            scoreList.list[indexPath.row].userScore = calculator.largeStraight
        case 12:
            scoreList.list[indexPath.row].userScore = calculator.yacht
        default:
            break
        }
        
        userTotalScoreLabel.text = "\(scoreList.userTotalScore)"
        opponentTotalScoreLabel.text = "\(scoreList.opponentTotalScore)"
        
        rule.opportunity = 3
        
    }
    
    func resetDiceImage() {
        for index in 0..<5 {
            
            if let lockedImageView = lockedDiceImageStackView.arrangedSubviews[index] as? UIImageView  {
                lockedImageView.image = nil
            }
            
            if lockedDices[index] != 0 {
                dices[index] = lockedDices[index]
                lockedDices[index] = 0
            }
            
            if let imageView = dicesImageStackView.arrangedSubviews[index] as? UIImageView  {
                
                let image = Dice(rawValue: dices[index])?.image
                imageView.image = image
            }
            
        }
        
    }
}

//MARK: - Rule

extension ViewController {
    
}

// MARK: - configuration

extension ViewController {
    
    private func configureTableView() {
        
        scoreTableView.delegate = self
        scoreTableView.dataSource = self
        
        scoreTableView.rowHeight = view.frame.height * 0.1
        
        let scoreCellXib = UINib(nibName: ScoreTableViewCell.identifier,
                                 bundle: nil)
        scoreTableView.register(scoreCellXib,
                                forCellReuseIdentifier: ScoreTableViewCell.identifier)
    }
    
    private func configureOpportunityView() {
        opportunityView.layer.cornerRadius = opportunityView.frame.width / 2
    }
}
