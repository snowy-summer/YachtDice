//
//  YachtDiceViewController.swift
//  YachtDice
//
//  Created by 최승범 on 5/30/24.
//

import UIKit
import GameKit
import Combine

final class YachtDiceViewController: UIViewController {
    
    @IBOutlet weak var scoreTableView: UITableView!
    @IBOutlet weak var unlockedDiceImageStackView: UIStackView!
    @IBOutlet weak var lockedDiceImageStackView: UIStackView!
    @IBOutlet weak var redTotalScoreLabel: UILabel!
    @IBOutlet weak var blueTotalScoreLabel: UILabel!
    @IBOutlet weak var opportunityView: UIView!
    @IBOutlet weak var opportunityLabel: UILabel!
    @IBOutlet weak var turnCountLabel: UILabel!
    
    @IBOutlet weak var blueNameLabel: UILabel!
    @IBOutlet weak var redNameLabel: UILabel!
    
    var match: GKMatch?
    private var cancellables = Set<AnyCancellable>()
    private var playerType: PlayerType!
    private var calculator = Calculator()
    private var gameModel: GameModel = GameModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        match?.delegate = self

        savePlayers()
        playerType = getLocalPlayerType()
        
        configureTableView()
        configureOpportunityView()
        configureDefualtLabelContent()
        bind()
        
    }
    
    private func bind() {
        
        gameModel.$playerType
            .sink { [weak self] newValue in
                guard let self = self else { return }
                resetDice(playerType: newValue)
            }
            .store(in: &cancellables)
        
        gameModel.$opportunity
            .sink { [weak self] newValue in
                guard let self = self else { return }

                opportunityLabel.text = "\(newValue)"
                
                if checkUserTurn() == false {
                    updateRollByData()
                }
                
            }
            .store(in: &cancellables)
        
        gameModel.$dices
            .sink { [weak self] newValue in
                guard let self = self else { return }
                
                calculator.unlockedDices = newValue
                updateUnlockedDiceImageByData(data: newValue)
            }
            .store(in: &cancellables)
        
        gameModel.$lockedDices
            .sink { [weak self] newValue in
                guard let self = self else { return }
                
                calculator.lockedDices = newValue
                updateLockedDiceImageByData(data: newValue)
            }
            .store(in: &cancellables)
        
        gameModel.$scoreList
            .compactMap { $0 }
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                redTotalScoreLabel.text = "\(gameModel.scoreList.redTotalScore)"
                blueTotalScoreLabel.text = "\(gameModel.scoreList.blueTotalScore)"
                scoreTableView.reloadData()
            }
            .store(in: &cancellables)
        
        gameModel.$totalTurn
            .compactMap { $0 }
            .sink { [weak self] newValue in
                guard let self = self else { return }
                
                turnCountLabel.text = "\(newValue) / 12"
                
                if newValue == 12 {
                    showGameResultAlert()
                }
            }
            .store(in: &cancellables)
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
            
            let images = redOrBlueDices(playerType: gameModel.playerType)
            
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
           let  diceImageView = unlockedDiceImageStackView.arrangedSubviews[lockedImageView.tag] as? UIImageView {
            
            let diceImages = redOrBlueDices(playerType: gameModel.playerType)
            
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
            guard let data = gameModel.encodeToData() else { return }
            try match.sendData(toAllPlayers: data,
                               with: .reliable)
        } catch {
            print("데이터 전달 실패")
        }
    }
    
}

//MARK: - GameUI

extension YachtDiceViewController {
    
    private func rolling() {
        
        for i in 0..<5 {
            if let randomDice = (1...6).randomElement(),
               let imageView = unlockedDiceImageStackView.arrangedSubviews[i] as? UIImageView  {
                let diceImages = redOrBlueDices(playerType: gameModel.playerType)
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
            
            if let imageView = unlockedDiceImageStackView.arrangedSubviews[i] as? UIImageView  {
                let diceImages = redOrBlueDices(playerType: gameModel.playerType)
                let image = diceImages[gameModel.dices[i] - 1]
                
                animatingImage(imageView: imageView)
                imageView.image = image
                
            }
        }
    }
    
    private func updateUnlockedDiceImageByData(data: [Int]) {
        
        for i in 0..<5 {
            guard let diceImageView = unlockedDiceImageStackView.arrangedSubviews[i] as? UIImageView else { return }
            let images = redOrBlueDices(playerType: gameModel.playerType)
            
            if data[i] != 0 {
                diceImageView.image = images[ data[i] - 1 ]
            } else {
                diceImageView.image = nil
            }
        }
    }
    
    private func updateLockedDiceImageByData(data: [Int]) {
        
        for i in 0..<5 {
            guard let lockedImageView = lockedDiceImageStackView.arrangedSubviews[i] as? UIImageView else { return }
            let images = redOrBlueDices(playerType: gameModel.playerType)
            
            if data[i] != 0 {
                lockedImageView.image = images[ data[i] - 1 ]
            } else {
                lockedImageView.image = nil
            }
        }
    }
    
    private func resetDice(playerType: PlayerType) {
        for index in 0..<5 {
            
            if let lockedImageView = lockedDiceImageStackView.arrangedSubviews[index] as? UIImageView  {
                lockedImageView.image = nil
            }
            
            if gameModel.lockedDices[index] != 0 {
                gameModel.dices[index] = gameModel.lockedDices[index]
                gameModel.lockedDices[index] = 0
            }
            
            if let imageView = unlockedDiceImageStackView.arrangedSubviews[index] as? UIImageView  {
                
                let diceImages = redOrBlueDices(playerType: playerType)
                
                let image = diceImages[gameModel.dices[index] - 1]
                imageView.image = image
            }
            
        }
    }
    
    private func animatingImage(imageView: UIImageView) {
        var diceImages = redOrBlueDices(playerType: gameModel.playerType)
        
        diceImages.shuffle()
        imageView.animationImages = diceImages
        imageView.animationDuration = 0.3
        imageView.animationRepeatCount = 2
        imageView.startAnimating()
        
    }
    
    private func redOrBlueDices(playerType: PlayerType) -> [UIImage] {
        switch playerType {
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
        guard let model = GameModel.decodeFromData(data: data) else {
            return
        }
        
        if gameModel.playerType != model.playerType {
            gameModel.playerType = model.playerType
        }
        
        if gameModel.opportunity != model.opportunity {
            gameModel.opportunity = model.opportunity
        }
        
        if gameModel.dices != model.dices {
            gameModel.dices = model.dices
        }
        
        if gameModel.lockedDices != model.lockedDices {
            gameModel.lockedDices = model.lockedDices
        }
        
        if gameModel.totalTurn != model.totalTurn {
            gameModel.totalTurn = model.totalTurn
        }
        
        gameModel.scoreList = model.scoreList
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
        if checkIsSelected(for: indexPath) { return }
        
        updateScore(for: indexPath,
                    playerType: playerType)
        
       
        changeTurn()
        resetDice(playerType: gameModel.playerType)
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
    
    private func checkIsSelected(for indexPath: IndexPath) -> Bool {
        
        if playerType == .red  && gameModel.scoreList.list[indexPath.row].isSelectedOfRed == false {
            gameModel.scoreList.list[indexPath.row].isSelectedOfRed = true
            return false
        } else if playerType == .blue && gameModel.scoreList.list[indexPath.row].isSelectedOfBlue == false {
            gameModel.scoreList.list[indexPath.row].isSelectedOfBlue = true
            return false
        }
        
        return true
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
