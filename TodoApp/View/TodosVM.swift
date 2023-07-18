//
//  todosVM.swift
//  TodoApp
//
//  Created by 김도훈 on 2023/06/20.
//

import Foundation

class TodosVM {
    
    var isChecked = false
    
    // 가공된 최종 데이터
    var todos: [Todo] = [] {
        didSet {
            self.notifyTodosChanged?(todos)
        }
    }
    

    
    // 검색어
    var searchTerm: String = "" {
        didSet {
            if searchTerm.count > 0 {
                self.searchTodos(searchTerm: searchTerm)
            } else {
                self.fetchTodos()
            }
        }
    }
    
    var pageInfo: Meta? = nil {
        didSet {
            // 다음페이지 있는지 여부 이벤트 보내기
            self.notifyHasNextPage?(pageInfo?.hasNext() ?? true)
            // 현재페이지 변경시 데이터 보내기
            self.notifyCurrentPageChanged?(currentPage)
        }
    }
    
    var currentPage: Int {
        get {
            if let pageInfo = self.pageInfo,
               let currentPage = pageInfo.currentPage {
                return currentPage
            } else {
                return 1
            }
        }
    }
    
    var isLoading: Bool = false {
        didSet {
            self.notifyLoadingStateChanged?(isLoading)
        }
    }
    
    var isCompleting: Bool = false {
        didSet {
            self.notifyTodosCompleted?(isCompleting)
        }
    }
    
    // 할일 완료 여부
    var notifyTodosCompleted: ((_ isCompleted: Bool) -> Void)? = nil
    
    // 삭제 이벤트
    var notifyDeleted: (() -> Void)? = nil
    
    // 에러 발생 이벤트
    var notifyErrorOccured: ((_ errMsg: String) -> Void)? = nil
    
    // 할 일 추가 이벤트
    var notifyTodoAdded: (() -> Void)? = nil
    
    // 다음 페이지 있는지 여부
    var notifyHasNextPage: ((_ hasNext: Bool) -> Void)? = nil
    
    // 검색결과 없음 여부 이벤트
    var notifySearchDataNotFound: ((_ noContent: Bool) -> Void)? = nil
    
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
    

    
    
    /// 할일 수정
    /// - Parameters:
    ///   - id: 수정할 데이터 아이디
    ///   - editedTitle: 수정할 내용
    func editATodo(_ id: Int, _ editedTitle: String, editedCompletion: @escaping () -> Void) {
        
        print(#fileID, #function, #line, "- editedTitle: \(editedTitle)")
        
        if isLoading {
            print("로딩중입니다")
            return
        }
        
        self.isLoading = true
        
        TodosAPI.editATodo(id: id,
                           title: editedTitle,
                           completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                self.isLoading = false
                if let editedATodo: Todo = response.data,
                   let editedTodoId: Int = editedATodo.id,
                   let editedIndex = self.todos.firstIndex(where: { $0.id ?? 0 == editedTodoId }) {
                    
                    // 지금 수정한 녀석의 아이디를 가지고 있는 인덱스 찾기
                    // 그 녀석을 바꾸기
                    self.todos[editedIndex] = editedATodo
                    editedCompletion()
                            
                }
            case .failure(let failure):
                self.isLoading = false
                self.handleError(failure)
            }
        })
    }
    
    
    /// 할일 삭제
    /// - Parameter id: 삭제될 아이디
    func deleteATodo(id: Int) {
        
        if isLoading {
            print("로딩중입니다.")
            return
        }
        
        self.isLoading = true
        
        TodosAPI.deleteATodo(id: id, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                self.isLoading = false
                if let deletedATodo: Todo = response.data,
                   let deletedTodoId: Int = deletedATodo.id {
                    
                    // 삭제된 아이템 찾아서 그 데이터만 현재 리스트에서 빼기
                    self.todos = self.todos.filter{ $0.id ?? 0 != deletedTodoId }
                    self.notifyDeleted?()
        
                }
            case .failure(let failure):
                self.isLoading = false
                self.handleError(failure)
            }
        })
    }
    
    
    /// 할 일 추가
    /// - Parameters:
    ///   - title: 할일
    func addATodo(title: String,
//                  isDone: Bool,
                  addedCompletion: @escaping () -> Void) {
        
        if isLoading {
            print("로딩중입니다.")
            return
        }
        
        self.isLoading = true

        TodosAPI.addATodoAndFetchTodos(title: title,
//                                       isDone: isDone,
                                       completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                self.isLoading = false
                // 페이지 갱신
                if let fetchedTodos: [Todo] = response.data,
                   let pageInfo: Meta = response.meta {
                    self.todos = fetchedTodos
                    self.pageInfo = pageInfo
                    self.notifyTodoAdded?()
                    addedCompletion()
//                    self.notifyTodosCompleted?(isDone)
                }
            case .failure(let failure):
                print("failure: \(failure)")
                self.isLoading = false
                self.handleError(failure)
            }
            self.notifyRefreshEnded?()
            self.fetchRefresh()
        })
    }
    
    
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
        
        guard pageInfo?.hasNext() ?? true else {
            return print("다음 페이지 없음")
        }
        
        self.notifySearchDataNotFound?(false)
        
        if page == 1 {
            self.todos = []
        }
        
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7 , execute: {
            // 서비스 로직
            TodosAPI.searchTodos(searchTerm: searchTerm,
                                 page: page,
                                 completion: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    self.isLoading = false
                    // 페이지 갱신
                    if let fetchedTodos: [Todo] = response.data,
                       let pageInfo: Meta = response.meta {
                        if page == 1 {
                            self.todos = fetchedTodos
                        } else {
                            self.todos.append(contentsOf: fetchedTodos)
                        }
                        self.pageInfo = pageInfo
                    }
                case .failure(let failure):
                    print("failure: \(failure)")
                    self.isLoading = false
                    self.handleError(failure)
                }
                self.notifyRefreshEnded?()
                
            })
        })
    }
    
    /// 데이터 리프레시
    func fetchRefresh() {
        self.fetchTodos(page: 1)
    }
    
    /// 더 가져오기
    func fetchMore() {
        
        guard let pageInfo = self.pageInfo,
                pageInfo.hasNext(),
                !isLoading else {
            return print("다음 페이지가 없습니다")
        }
        
        if searchTerm.count > 0 { // 검색어가 있으면
            self.searchTodos(searchTerm: searchTerm, page: self.currentPage + 1)
        } else {
            self.fetchTodos(page: currentPage + 1)
        }
    }
    
    /// 할 일 가져오기
    /// - Parameter page: 페이지
    func fetchTodos(page: Int = 1, isDone: Bool = false) {
        
        if isLoading {
            print("로딩중입니다")
            return
        }
        
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7 , execute: {
            // 서비스 로직
            TodosAPI.fetchTodos(page: page,
                                completion: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    self.isLoading = false
                    // 페이지 갱신
                    
                    if let fetchedTodos: [Todo] = response.data,
                       let pageInfo: Meta = response.meta {
                        if page == 1 {
                            self.todos = fetchedTodos
                        } else {
                            self.todos.append(contentsOf: fetchedTodos)
                        }
                        self.pageInfo = pageInfo
                    }
                case .failure(let failure):
                    print("failure: \(failure)")
                    self.isLoading = false
                }
                
                self.notifyRefreshEnded?()
                
            })
        })
    }
    
    
    fileprivate func handleError(_ error: Error) {
        
        guard let apiError = error as? TodosAPI.ApiError else {
            print("모르는 에러입니다")
            return
        }
        
        print("handleError: Error: \(apiError.info)")
        
        switch apiError {
        case .noContentsError:
            print("컨텐츠 없음")
            self.notifySearchDataNotFound?(true)
        case .unauthorizedError:
            print("인증 안됨")
        case .decodingError:
            print("디코딩 에러")
        case .erroResponseFromServer:
            print("서버에서 온 에러: \(apiError.info)")
            self.notifyErrorOccured?(apiError.info)
        default:
            print("default")
            
        }
    }// handleError
    
}
