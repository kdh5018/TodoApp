//
//  UIScrollView+Reactive.swift
//  TodoApp
//
//  Created by 김도훈 on 2023/08/14.
//

import Foundation
import UIKit
import RxSwift
import RxRelay
import RxCocoa

extension Reactive where Base: UIScrollView {
    
    
    /// 바닥 여부
    var bottomReached: Observable<Void> {
        
        return contentOffset.map { (offset: CGPoint) in
            let height: CGFloat = self.base.frame.size.height
            let contentYOffset: CGFloat = offset.y
            let distanceFromBottom: CGFloat = self.base.contentSize.height - contentYOffset
            
            return distanceFromBottom  - 200 < height
        }
        .filter{ $0 == true }.map{ _ in }
    }
}

