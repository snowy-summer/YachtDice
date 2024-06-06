//
//  YachtDiceViewController.swift
//  YachtDice
//
//  Created by 최승범 on 5/30/24.
//

import UIKit
import GameKit

final class YachtDiceViewController: UIViewController {
    
    @IBOutlet weak var scoreTableView: UITableView!
    @IBOutlet weak var dicesImageStackView: UIStackView!
    @IBOutlet weak var lockedDiceImageStackView: UIStackView!
    @IBOutlet weak var redTotalScoreLabel: UILabel!
    @IBOutlet weak var blueTotalScoreLabel: UILabel!
    @IBOutlet weak var opportunityView: UIView!
    @IBOutlet weak var opportunityLabel: UILabel!
    @IBOutlet weak var turnCountLabel: UILabel!
    
    @IBOutlet weak var blueNameLabel: UILabel!
    @IBOutlet weak var redNameLabel: UILabel!
    
    var match: GKMatch?
    private var playerType: PlayerType!
    private var calculator = Calculator()
    
    private var gameModel: GameModel! {
        didSet {
            updateUI()
            updateCalculatorDice()
            
            if gameModel.totalTurn == 12 {
                showGameResultAlert()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        match?.delegate = self
        gameModel = GameModel()
        savePlayers()
        playerType = getLocalPlayerType()
        
        configureTableView()
        configureOpportunityView()
        configureDefualtLabelContent()
        
    }
    
    @IBAction func lockDice(_ sender: UITapGestureRecognizer) {
        
        if checkUserTurn() == false {
            showNotYourTurnAlert()
            return
        }
        
        if checkFirstRoll() == false {
            showRequestRollAlert()
            return
        }
        
        if let imageView = sender.view as? UIImageView,
           let  lockedImageView = lockedDiceImageStackView.arrangedSubviews[imageView.tag] as? UIImageView {
            
            let images = redOrBlueDices()
            
            if gameModel.dices[imageView.tag] == 0 { return }
            
            lockedImageView.image = images[gameModel.dices[imageView.tag] - 1]
            imageView.image = nil
            
            gameModel.lockedDices[imageView.tag] = gameModel.dices[imageView.tag]
            gameModel.dices[imageView.tag] = 0
        }
        
        sendData()
    }
    
    @IBAction func unlockDice(_ sender: UITapGestureRecognizer) {
        
        if checkUserTurn() == false {
            showNotYourTurnAlert()
            return
        }
        
        if let lockedImageView = sender.view as? UIImageView,
           let  diceImageView = dicesImageStackView.arrangedSubviews[lockedImageView.tag] as? UIImageView {
            
            let diceImages = redOrBlueDices()
            
            if gameModel.lockedDices[lockedImageView.tag] == 0 { return }
            
            diceImageView.image = diceImages[gameModel.lockedDices[lockedImageView.tag] - 1]
            lockedImageView.image = nil
            
            gameModel.dices[lockedImageView.tag] = gameModel.lockedDices[lockedImageView.tag]
            gameModel.lockedDices[lockedImageView.tag] = 0
            
        }
        
        sendData()
    }
    
    @IBAction func rollTheDice(_ sender: UIButton) {
        if checkUserTurn() == false {
            showNotYourTurnAlert()
            return
        }
        
        if gameModel.opportunity == 0 { return }
        gameModel.opportunity -= 1
        rolling()
        sendData()
    }
}

//MARK: - GameData

extension YachtDiceViewController {
    
    private func savePlayers() {
        guard let player2Name = match?.players.first?.displayName else { return }
        
        let player1 = Player(displayName: GKLocalPlayer.local.displayName)
        let player2 = Player(displayName: player2Name)
        
        gameModel.players = [ player1, player2 ]
        gameModel.players.sort { player1, player2 in
            player1.displayName < player2.displayName
        }
        
        sendData()
    }
    
    private func getLocalPlayerType() ->PlayerType {
        if gameModel.players.first?.displayName == GKLocalPlayer.local.displayName {
            return .blue
        } else {
            return .red
        }
    }
    
    private func updateCalculatorDice() {
        calculator.dices = (gameModel.dices + gameModel.lockedDices).filter { $0 != 0 }
    }
    
    
    private func changeTurn() {
        
        gameModel.opportunity = 3
        
        if gameModel.playerType == .blue {
            gameModel.playerType = .red
        } else {
            gameModel.totalTurn += 1
            gameModel.playerType = .blue
        }
        
    }
    
    private func sendData() {
        guard let match = match else { return }
        
        do {
            guard let data = gameModel.encode() else { return }
            try match.sendData(toAllPlayers: data,
                               with: .reliable)
        } catch {
            print("데이터 전달 실패")
        }
    }
    
}

//MARK: - GameUI

extension YachtDiceViewController {
    
    private func updateUI() {
        if gameModel.players.count < 2 { return }
        
        opportunityLabel.text = "\(gameModel.opportunity)"
        redTotalScoreLabel.text = "\(gameModel.scoreList.redTotalScore)"
        blueTotalScoreLabel.text = "\(gameModel.scoreList.blueTotalScore)"
        turnCountLabel.text = "\(gameModel.totalTurn) / 12"
        if checkUserTurn() == false {
            updateDiceByData()
            updateRollByData()
            // combine같은 걸로 세분화해서 업데이트 하는게 맞는 것 같다.
        }
        scoreTableView.reloadData()
        
    }
    
    private func rolling() {
        
        for i in 0..<5 {
            if let randomDice = (1...6).randomElement(),
               let imageView = dicesImageStackView.arrangedSubviews[i] as? UIImageView  {
                let diceImages = redOrBlueDices()
                let image = diceImages[randomDice - 1]
                
                if gameModel.dices[i] != 0 {
                    gameModel.dices[i] = randomDice
                    animatingImage(imageView: imageView)
                    imageView.image = image
                }
            }
        }
    }
    
    private func updateRollByData() {
        for i in 0..<5 {
            
            if gameModel.dices[i] == 0 {
                continue
            }
            
            if let imageView = dicesImageStackView.arrangedSubviews[i] as? UIImageView  {
                let diceImages = redOrBlueDices()
                let image = diceImages[gameModel.dices[i] - 1]
                
                animatingImage(imageView: imageView)
                imageView.image = image
                
            }
        }
    }
    
    private func updateDiceByData() {
        for i in 0..<5 {
            guard let diceImageView = dicesImageStackView.arrangedSubviews[i] as? UIImageView,
                  let lockedImageView = lockedDiceImageStackView.arrangedSubviews[i] as? UIImageView else { return }
            let images = redOrBlueDices()
            
            if gameModel.lockedDices[i] != 0 {
                lockedImageView.image = images[gameModel.lockedDices[i] - 1]
            } else {
                lockedImageView.image = nil
            }
            
            if gameModel.dices[i] != 0 {
                diceImageView.image = images[gameModel.dices[i] - 1]
            } else {
                diceImageView.image = nil
            }
        }
    }
    
    private func resetDice() {
        for index in 0..<5 {
            
            if let lockedImageView = lockedDiceImageStackView.arrangedSubviews[index] as? UIImageView  {
                lockedImageView.image = nil
            }
            
            if gameModel.lockedDices[index] != 0 {
                gameModel.dices[index] = gameModel.lockedDices[index]
                gameModel.lockedDices[index] = 0
            }
            
            if let imageView = dicesImageStackView.arrangedSubviews[index] as? UIImageView  {
                
                let diceImages = redOrBlueDices()
                
                let image = diceImages[gameModel.dices[index] - 1]
                imageView.image = image
            }
            
        }
    }
    
    private func animatingImage(imageView: UIImageView) {
        var diceImages = redOrBlueDices()
        
        diceImages.shuffle()
        imageView.animationImages = diceImages
        imageView.animationDuration = 0.3
        imageView.animationRepeatCount = 2
        imageView.startAnimating()
        
    }
    
    private func redOrBlueDices() -> [UIImage] {
        switch gameModel.playerType {
        case.blue:
            let blueOneToSixDiceImages = [
                UIImage(resource: .blueOneDice),
                UIImage(resource: .blueTwoDice),
                UIImage(resource: .blueThreeDice),
                UIImage(resource: .blueFourDice),
                UIImage(resource: .blueFiveDice),
                UIImage(resource: .blueSixDice),
            ]
            return blueOneToSixDiceImages
            
        case.red:
            let redOneToSixDiceImages = [
                UIImage(resource: .redOneDice),
                UIImage(resource: .redTwoDice),
                UIImage(resource: .redThreeDice),
                UIImage(resource: .redFourDice),
                UIImage(resource: .redFiveDice),
                UIImage(resource: .redSixDice),
            ]
            return redOneToSixDiceImages
        }
    }
    
}

//MARK: - GKMatchDelegate

extension YachtDiceViewController: GKMatchDelegate {
    func match(_ match: GKMatch,
               didReceive data: Data,
               fromRemotePlayer player: GKPlayer) {
        guard let model = GameModel.decode(data: data) else {
            return
        }
        gameModel = model
    }
}

//MARK: -  TableView Delegate, DataSource

extension YachtDiceViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return gameModel.scoreList.list.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ScoreTableViewCell.identifier) as? ScoreTableViewCell else { return ScoreTableViewCell() }
        
        
        cell.updateContent(data: gameModel.scoreList.list[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        
        if checkUserTurn() == false {
            showNotYourTurnAlert()
            return
        }
        
        if checkFirstRoll() == false {
            showRequestRollAlert()
            return
        }
        
        if indexPath.row == 6 { return }
        
        updateScore(for: indexPath,
                    playerType: playerType)
        
       
        resetDice()
        changeTurn()
        sendData()
    }
    
    private func updateScore(for indexPath: IndexPath, playerType: PlayerType) {
        let score: Int
        
        switch indexPath.row {
        case 0...5:
            score = calculator.countOfDice(num: indexPath.row + 1)
        case 7:
            score = calculator.choice
        case 8:
            score = calculator.fourOfKind
        case 9:
            score = calculator.fullHouse
        case 10:
            score = calculator.smallStraight
        case 11:
            score = calculator.largeStraight
        case 12:
            score = calculator.yacht
        default:
            return
        }
        
        if playerType == .red {
            gameModel.scoreList.list[indexPath.row].redScore = score
            if indexPath.row <= 5 {
                gameModel.scoreList.list[6].redScore = gameModel.scoreList.redSubtotalScore
            }
        } else {
            gameModel.scoreList.list[indexPath.row].blueScore = score
            if indexPath.row <= 5 {
                gameModel.scoreList.list[6].blueScore = gameModel.scoreList.blueSubtotalScore
            }
        }
    }
    
}

//MARK: - CheckRule

extension YachtDiceViewController {
    
    private func checkFirstRoll() -> Bool {
        return gameModel.opportunity == 3 ? false : true
    }
    
    private func checkUserTurn() -> Bool {
        return gameModel.playerType == playerType
    }
}

//MARK: - Alert

extension YachtDiceViewController {
    
    private func showRequestRollAlert() {
        
        let noticeAlert = UIAlertController(title: "알림",
                                            message: "주사위를 굴리세요",
                                            preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "확인",
                                          style: .cancel)
        
        noticeAlert.addAction(confirmAction)
        
        self.present(noticeAlert,
                     animated: true)
    }
    
    private func showNotYourTurnAlert() {
        let noticeAlert = UIAlertController(title: "알림",
                                            message: "당신의 턴이 아닙니다", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "확인",
                                          style: .cancel)
        
        noticeAlert.addAction(confirmAction)
        
        self.present(noticeAlert,
                     animated: true)
    }
    
    private func showGameResultAlert() {
        
        let winner: String
        
        if gameModel.scoreList.blueTotalScore > gameModel.scoreList.redTotalScore {
            winner = "Blue 승리!"
        } else if gameModel.scoreList.blueTotalScore < gameModel.scoreList.redTotalScore{
            winner = "Red 승리!"
        } else {
            winner = "무승부"
        }
        let noticeAlert = UIAlertController(title: "알림",
                                            message: winner, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "확인",
                                          style: .cancel) {[weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        
        noticeAlert.addAction(confirmAction)
        
        self.present(noticeAlert,
                     animated: true)
    }
}

// MARK: - configuration

extension YachtDiceViewController {
    
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
    
    private func configureDefualtLabelContent() {
        opportunityLabel.text = "3"
        turnCountLabel.text = "0 / 12"
        
        redNameLabel.text = gameModel.players[1].displayName
        redNameLabel.textColor = UIColor(resource: .redPlayer)
        blueNameLabel.text = gameModel.players[0].displayName
        blueNameLabel.textColor = UIColor(resource: .bluePlayer)
        redTotalScoreLabel.textColor = UIColor(resource: .redPlayer)
        blueTotalScoreLabel.textColor = UIColor(resource: .bluePlayer)
        
    }
}
