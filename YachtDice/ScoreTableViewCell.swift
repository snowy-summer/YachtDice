//
//  ScoreTableViewCell.swift
//  YachtDice
//
//  Created by 최승범 on 5/30/24.
//

import UIKit

final class ScoreTableViewCell: UITableViewCell {

    @IBOutlet weak var scoreImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var userScoreLabel: UILabel!
    @IBOutlet weak var opponentScoreLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func updateContent(data: Score) {
        scoreImageView.image = data.image
        titleLabel.text = data.title
        userScoreLabel.text = "\(data.userScore)"
        opponentScoreLabel.text = "\(data.opponentScore)"
        
        if data.title == "Subtotal" {
            userScoreLabel.text = data.subtotalUserScore
            opponentScoreLabel.text = data.subtotalopponentScore
        }
        
        backgroundColor = .white
    }
}
