//
//  GKTurnBaseMatch+Extension.swift
//  YachtDice
//
//  Created by 최승범 on 6/2/24.
//

import GameKit

extension GKTurnBasedMatch {
  var isLocalPlayersTurn: Bool {
    return currentParticipant?.player == GKLocalPlayer.local
  }
  
  var others: [GKTurnBasedParticipant] {
    return participants.filter {
      return $0.player != GKLocalPlayer.local
    }
  }
}
