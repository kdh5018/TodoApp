//
//  Nibbed.swift
//  TodoApp
//
//  Created by 김도훈 on 2023/06/12.
//

import Foundation
import UIKit


protocol Nibbed {
    static var uinib: UINib { get }
}

extension Nibbed {
    static var uinib: UINib {
        return UINib(nibName: String(describing: Self.self), bundle: nil)
    }
}

extension UITableViewCell: Nibbed { }
