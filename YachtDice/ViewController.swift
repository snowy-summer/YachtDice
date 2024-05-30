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
    private let scoreList = ScoreList().list
    private var calculator = Calculator()

    @IBOutlet weak var DicesImage: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
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

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scoreList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ScoreTableViewCell.identifier) as? ScoreTableViewCell else { return ScoreTableViewCell() }
        
        
        cell.updateContent(data: scoreList[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row <= 5 {
            print(calculator.countOfDice(num: indexPath.row + 1))
        }
        
    }
    
    
    
}


// MARK: - configuration
extension ViewController {
    
    private func configureTableView() {
        
        ScoreTableView.delegate = self
        ScoreTableView.dataSource = self
        
        ScoreTableView.rowHeight = view.frame.height * 0.1
        
        let scoreCellXib = UINib(nibName: "ScoreTableViewCell",
                                 bundle: nil)
        ScoreTableView.register(scoreCellXib,
                                forCellReuseIdentifier: ScoreTableViewCell.identifier)
    }
}
