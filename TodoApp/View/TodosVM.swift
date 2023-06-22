//
//  todosVM.swift
//  TodoApp
//
//  Created by 김도훈 on 2023/06/20.
//

import Foundation

class TodosVM {
    
    
    
    fileprivate func handleError(_ error: Error) {
        if error is TodosAPI.ApiError {
            let apiError = error as! TodosAPI.ApiError
            
            print("handleError: Error: \(apiError.info)")
            
            switch apiError {
            case .noContentsError:
                print("컨텐츠 없음")
            case .unauthorizedError:
                print("인증 안됨")
            default:
                print("default")
            }
        }
    }
    
}
