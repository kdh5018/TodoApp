//
//  Optional+Ext.swift
//  TodoApp
//
//  Created by 김도훈 on 2023/08/09.
//

import Foundation

extension Optional {
    init<T, U>(tuple: (T?, U?)) where Wrapped == (T, U) {
        
        switch tuple{
            case (let t?, let u?):
            self = (t, u)
        default:
            self = nil
        }
    }
}
