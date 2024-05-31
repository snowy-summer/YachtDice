//
//  Identifier+Extension.swift
//  YachtDice
//
//  Created by 최승범 on 5/31/24.
//

import UIKit

protocol ReuseIdentifier {
    static var identifier: String { get }
}

extension UIView: ReuseIdentifier {
    static var identifier: String {
        return String(describing: self)
    }
}

extension UIViewController: ReuseIdentifier {
    static var identifier: String {
        return String(describing: self)
    }
}
