//
//  todosVM.swift
//  TodoApp
//
//  Created by 김도훈 on 2023/06/20.
//

import Foundation

class TodosVM {
    
    // 가공된 최종 데이터
    var todos: [Todo] = [] {
        didSet {
            self.notifyTodosChanged?(todos)
        }
    }
    
    // 검색어
    var searchTerm: String = "" {
        didSet {
            self.searchTodos(searchTerm: searchTerm)
        }
    }
    
    var currentPage: Int = 1 {
        didSet {
            self.notifyCurrentPageChanged?(currentPage)
        }
    }
    
    var isLoading: Bool = false {
        didSet {
            self.notifyLoadingStateChanged?(isLoading)
        }
    }
    
    // 리프레시 완료 이벤트
    var notifyRefreshEnded: (() -> Void)? = nil
    
    // 데이터 변경 이벤트
    var notifyLoadingStateChanged: ((_ isLoading: Bool) -> Void)? = nil
    
    // 데이터 변경 이벤트
    var notifyTodosChanged: (([Todo]) -> Void)? = nil
    
    // 현재페이지 변경 이벤트
    var notifyCurrentPageChanged: ((Int) -> Void)? = nil
    
    init() {
        fetchTodos()
    }// init
    
    /// 할 일 검색
    /// - Parameters:
    ///   - searchTerm: 검색어
    ///   - page: 페이지
    func searchTodos(searchTerm: String, page: Int = 1) {
        
        if searchTerm.count < 1 {
            print("검색어가 없음")
            return
        }
        
        if isLoading {
            print("로딩중입니다")
            return
        }
        
        self.todos = []
        
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7 , execute: {
            // 서비스 로직
            TodosAPI.searchTodos(searchTerm: searchTerm,
                                 page: page,
                                 completion: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    // 페이지 갱신
                    self.currentPage = page
                    if let fetchedTodos: [Todo] = response.data {
                        if page == 1 {
                            self.todos = fetchedTodos
                        } else {
                            self.todos.append(contentsOf: fetchedTodos)
                        }
                        
                    }
                case .failure(let failure):
                    print("failure: \(failure)")
                }
                self.notifyRefreshEnded?()
                self.isLoading = false
            })
        })
    }
    
    func fetchRefresh() {
        self.fetchTodos(page: 1)
    }
    
    /// 더 가져오기
    func fetchMore() {
        self.fetchTodos(page: currentPage + 1)
    }
    
    /// 할 일 가져오기
    /// - Parameter page: 페이지
    func fetchTodos(page: Int = 1) {
        
        if isLoading {
            print("로딩중입니다")
            return
        }
        
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7 , execute: {
            // 서비스 로직
            TodosAPI.fetchTodos(page: 1,
                                completion: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    // 페이지 갱신
                    self.currentPage = page
                    if let fetchedTodos: [Todo] = response.data {
                        if page == 1 {
                            self.todos = fetchedTodos
                        } else {
                            self.todos.append(contentsOf: fetchedTodos)
                        }
                        
                    }
                case .failure(let failure):
                    print("failure: \(failure)")
                }
                self.notifyRefreshEnded?()
                self.isLoading = false
            })
        })
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
