//
//  GameCenterLoginViewController.swift
//  YachtDice
//
//  Created by 최승범 on 6/2/24.
//

import UIKit
import GameKit

final class GameCenterLoginViewController: UIViewController {

    @IBOutlet weak var playButton: UIButton!

    private var gameCenterHelper: GameCenterHelper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configurePlayButton()
        
        gameCenterHelper = GameCenterHelper()
        gameCenterHelper.delegate = self
        gameCenterHelper.authenticatePlayer()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? YachtDiceViewController,
              let match = sender as? GKMatch else { return }
        
        vc.match = match
    }
    
    @IBAction func playButtonClicked(_ sender: UIButton) {
        
      gameCenterHelper.presentMatchmaker()
    }
    
    private func configurePlayButton() {
        playButton.isEnabled = false
    }
}

extension GameCenterLoginViewController: GameCenterHelperDelegate {
    func didChangeAuthStatus(isAuthenticated: Bool) {
        playButton.isEnabled = isAuthenticated
    }
    
    func presentGameCenterAuth(viewController: UIViewController?) {
        guard let vc = viewController else {return}
        self.present(vc, animated: true)
    }
    
    func presentMatchmaking(viewController: UIViewController?) {
        guard let vc = viewController else {return}
        self.present(vc, animated: true)
    }
    
    func presentGame(match: GKMatch) {
        performSegue(withIdentifier: "showGame", sender: match)
    }
}
