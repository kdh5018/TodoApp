//
//  todosVM.swift
//  TodoApp
//
//  Created by 김도훈 on 2023/06/20.
//

import Foundation
import Combine

class TodosVM: ObservableObject {
    
    init() {
        TodosAPI.fetchTodos { [weak self] result in
            
            guard let self = self else { return }
                    
            switch result {
            case .success(let todosResponse):
                print("todosVM - todosResponse: \(todosResponse)")
            case .failure(let failure):
                print("todosVM - failure: \(failure)")
                self.handleError(failure)
            }
        }
    }
    
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
