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
    
    @IBOutlet weak var redScoreLabel: UILabel!
    @IBOutlet weak var blueScoreLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func updateContent(data: Score) {
        scoreImageView.image = UIImage(named: "\(data.dice.scoreImageString)")
        titleLabel.text = data.dice.title
        
        redScoreLabel.text = "\(data.redScore)"
        redScoreLabel.textColor = UIColor(resource: .redPlayer)
        blueScoreLabel.text = "\(data.blueScore)"
        blueScoreLabel.textColor = UIColor(resource: .bluePlayer)
        
        if data.dice == .bonus {
            redScoreLabel.text = data.subtotalRedScore
            blueScoreLabel.text = data.subtotalBlueScore
        }
        
        backgroundColor = .white
    }
}
