//
//  TodosVM_Rx.swift
//  TodoApp
//
//  Created by 김도훈 on 2023/08/07.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

class TodosVM_Rx {
    
    // 1. Observable
    // 2. BehaviorRelay - .value
    // 3. PublishRelay
    
    var isChecked: Bool = false
    
    var todoTableViewCell: TodoTableViewCell = TodoTableViewCell()
    
    var disposeBag: DisposeBag = DisposeBag()
    
    // 가공된 최종 데이터
    var todos: BehaviorRelay<[Todo]> = BehaviorRelay<[Todo]>(value: [])
    
    var isLoading: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    struct Output {
        
        var notifyRefreshEnded: PublishSubject<Void> = PublishSubject<Void>()
        
        var notifySearchDataNotFound: PublishSubject<Bool> = PublishSubject<Bool>()
        
//        var notifyHasNextPage: PublishSubject<Bool> = PublishSubject<Bool>()
        
        var notifyTodoAdded: PublishSubject<Void> = PublishSubject<Void>()
        
        var notifyTodoCheckChanged: PublishSubject<(Int, Bool)> = PublishSubject<(Int, Bool)>()
        
        var notifyErrorOccured: PublishSubject<String> = PublishSubject<String>()
        
        var notifyTodosCompleted: PublishSubject<Bool> = PublishSubject<Bool>()
        
        var notifyDeleted: PublishSubject<Void> = PublishSubject<Void>()
        
//        var notifyCurrentPageChanged: PublishSubject<Int> = PublishSubject<Int>()
        
    }

    var output: Output = Output()

    
    // 검색어
//    var searchTerm: String = "" {
//        didSet {
//            if searchTerm.count > 0 {
//                self.searchTodos(searchTerm: searchTerm)
//            } else {
//                self.fetchTodos()
//            }
//        }
//    }
    
    var searchTerm: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
    
    var pageInfo: BehaviorRelay<Meta?> = BehaviorRelay<Meta?>(value: nil)
    
    // 다음페이지 있는지 이벤트
    var notifyHasNextPage: Observable<Bool>
    
    var currentPage: BehaviorRelay<Int> = BehaviorRelay<Int>(value: 1)
    
    var currentPageInfo: Observable<String>
    
//    var isCompleting: Bool = false {
//        didSet {
////            self.output.notifyTodosCompleted?(isCompleting)
//            self.output.notifyTodosCompleted.onNext(isCompleting)
////            self.notifyTodosCompleted?(isCompleting)
//        }
//    }
    
//    // 할일 완료 여부
//    var notifyTodosCompleted: ((_ isCompleted: Bool) -> Void)? = nil
//
//    // 삭제 이벤트
//    var notifyDeleted: (() -> Void)? = nil
//
//    // 에러 발생 이벤트
//    var notifyErrorOccured: ((_ errMsg: String) -> Void)? = nil
    
//    // 할 일 추가 이벤트
//    var notifyTodoAdded: (() -> Void)? = nil
    
//    // 다음 페이지 있는지 여부
//    var notifyHasNextPage: ((_ hasNext: Bool) -> Void)? = nil
    
//    // 검색결과 없음 여부 이벤트
//    var notifySearchDataNotFound: ((_ noContent: Bool) -> Void)? = nil
    
//    // 리프레시 완료 이벤트
//    var notifyRefreshEnded: (() -> Void)? = nil
    
//    // 데이터 변경 이벤트
//    var notifyLoadingStateChanged: ((_ isLoading: Bool) -> Void)? = nil
    
//    // 데이터 변경 이벤트
//    var notifyTodosChanged: (([Todo]) -> Void)? = nil
    
//    // 현재페이지 변경 이벤트
//    var notifyCurrentPageChanged: ((Int) -> Void)? = nil
    
//    // 4.
//    // 어떤 녀석이 체크가 변경되었는지 알려주기
//    var notifyTodoCheckChanged: ((Int, Bool) -> Void)? = nil

    
//    struct Output {
        // 할일 완료 여부
//        var notifyTodosCompleted: ((_ isCompleted: Bool) -> Void)? = nil
        
        // 삭제 이벤트
//        var notifyDeleted: (() -> Void)? = nil
        
        // 에러 발생 이벤트
//        var notifyErrorOccured: ((_ errMsg: String) -> Void)? = nil
        
//        // 데이터 변경 이벤트
//        var notifyTodosChanged: (([Todo]) -> Void)? = nil
        
        // 현재페이지 변경 이벤트
//        var notifyCurrentPageChanged: ((Int) -> Void)? = nil
        
//        // 데이터 변경 이벤트
//        var notifyLoadingStateChanged: ((_ isLoading: Bool) -> Void)? = nil
        
        // 리프레시 완료 이벤트
//        var notifyRefreshEnded: (() -> Void)? = nil
        
        // 검색결과 없음 여부 이벤트
//        var notifySearchDataNotFound: ((_ noContent: Bool) -> Void)? = nil
        
        // 할 일 추가 이벤트
//        var notifyTodoAdded: (() -> Void)? = nil
        
        // 다음 페이지 있는지 여부
//        var notifyHasNextPage: ((_ hasNext: Bool) -> Void)? = nil
        
        // 4.
        // 어떤 녀석이 체크가 변경되었는지 알려주기
//        var notifyTodoCheckChanged: ((Int, Bool) -> Void)? = nil
//    }
    
    init() {
        currentPageInfo = self.currentPage.map{ "⭐️페이지: \($0)" }
        
        pageInfo
            .compactMap{ $0 } // Meta
            .map{ if let currentPage = $0.currentPage {
                    return currentPage
                } else {
                    return 1
                }
            }
            .bind(onNext: self.currentPage.accept(_:))
            .disposed(by: disposeBag)
        
        self.notifyHasNextPage = pageInfo.skip(1).map{ $0?.hasNext() ?? true } // Observable<Bool>
        
        searchTerm
            .withUnretained(self)
            .do(onNext: { _ in
                self.todos.accept([])
            })
            .debounce(RxTimeInterval.milliseconds(700), scheduler: MainScheduler.instance)
            .subscribe(onNext: { vm, searchTerm in
                if searchTerm.count > 0 {
                    self.pageInfo.accept(nil)
                    self.currentPage.accept(1)
                    vm.searchTodos(searchTerm: searchTerm)
                } else {
                    vm.fetchTodos()
                }
            })
            .disposed(by: disposeBag)
        
//        fetchTodos()
        
    }// init
    
    
    // ⭐️ 액션으로 나누기
    enum InputAction {
        case handleToggleTodo(existingTodo: Todo, checked: Bool)
        case deleteATodo(id: Int)
        case searchTodos(searchTerm: String, page: Int = 1)
        case editATodo(_ id: Int, _ editedTitle: String, _ isDone: Bool)
        case addATodo(title: String, isDone: Bool)
        case fetchRefresh
        case fetchMore
    }
    
    // 액션함수들 스위치 케이스로 구분
    func handleInputAction(action: InputAction) {
        print(#fileID, #function, #line, "- ")
        switch action {
        case .handleToggleTodo(let existingTodo, let checked):
            self.handleToggleTodo(existingTodo: existingTodo, checked: checked)
        case .deleteATodo(let id):
            self.deleteATodo(id: id)
        case .searchTodos(let searchTerm, let page):
            self.searchTodos(searchTerm: searchTerm, page: page)
        case .editATodo(let id, let editedTitle, let isDone):
            self.editATodo(id, editedTitle, isDone) {}
        case .addATodo(let title, let isDone):
            self.addATodo(title: title, isDone: isDone) {}
        case .fetchRefresh:
            self.fetchRefresh()
        case .fetchMore:
            self.fetchMore()

        default:
            break
        }
    }
    
    // INPUT -> VM
    // 2.
    fileprivate func handleToggleTodo(existingTodo: Todo, checked: Bool) {
        
        guard let id: Int = existingTodo.id,
              let title: String = existingTodo.title else { return }
        
        // Transform
        // 3.
        self.editATodoIsDone(id, title, checked, editedCompletion: { id, checked in
            // 재료를 줬음
            // OUTPUT <- VM
//            self.output.notifyTodoCheckChanged?(id, checked)
            self.output.notifyTodoCheckChanged.onNext((id,checked))
            if checked == true {
                self.todoTableViewCell.isCheckedFunc()
            } else {
                self.todoTableViewCell.isUnCheckedFunc()
            }
        })
    }
    
    fileprivate func editATodoIsDone(_ id: Int, _ editedTitle: String, _ isDone: Bool, editedCompletion: @escaping (_ id: Int, _ checked: Bool) -> Void) {
        
        print(#fileID, #function, #line, "- editedTitle: \(editedTitle)")
        
        if isLoading.value {
            print("로딩중입니다")
            return
        }
        
        self.isLoading.accept(true)
        
        TodosAPI.editATodoWithObservable(id: id, title: editedTitle, isDone: isDone)
            .do(onError: { (failure: Error) in
                self.isLoading.accept(false)
                self.handleError(failure)
            },onCompleted: {
                self.isLoading.accept(false)
            })
            .subscribe(onNext: { response in
                if let editedATodo: Todo = response.data,
                   let editedTodoId: Int = editedATodo.id,
                   let editedChecked: Bool = editedATodo.isDone {
                    editedCompletion(editedTodoId, editedChecked)
                }
            }).disposed(by: disposeBag)
    }
    
    /// 할일 수정
    /// - Parameters:
    ///   - id: 수정할 데이터 아이디
    ///   - editedTitle: 수정할 내용
    fileprivate func editATodo(_ id: Int, _ editedTitle: String, _ isDone: Bool, editedCompletion: @escaping () -> Void) {
        
        print(#fileID, #function, #line, "- editedTitle: \(editedTitle)")
        
        if isLoading.value {
            print("로딩중입니다")
            return
        }
        
        self.isLoading.accept(true)
        
        TodosAPI.editATodoWithObservable(id: id, title: editedTitle, isDone: isDone)
            .do(onError: { (failure: Error) in
                self.isLoading.accept(false)
                self.handleError(failure)
            },onCompleted: {
                self.isLoading.accept(false)
            })
            .subscribe(onNext: { response in
                if let editedATodo: Todo = response.data,
                   let editedTodoId: Int = editedATodo.id,
                   let editedIndex = self.todos.value.firstIndex(where: { $0.id ?? 0 == editedTodoId }) {
                    
                    // 지금 수정한 녀석의 아이디를 가지고 있는 인덱스 찾기
                    // 그 녀석을 바꾸기
                    
                    var currentTodos: [Todo] = self.todos.value
                    currentTodos[editedIndex] = editedATodo
                    
                    self.todos.accept(currentTodos)
                    
                    editedCompletion()
                            
                }
            }).disposed(by: disposeBag)
    }
    
    
    /// 할일 삭제
    /// - Parameter id: 삭제될 아이디
    fileprivate func deleteATodo(id: Int) {
        
        if isLoading.value {
            print("로딩중입니다.")
            return
        }
        
        self.isLoading.accept(true)
        
        TodosAPI.deleteATodoWithObservable(id: id)
            .do(onError: { (failure: Error) in
                self.isLoading.accept(false)
                self.handleError(failure)
            },onCompleted: {
                self.isLoading.accept(false)
            })
            .subscribe(onNext: { response in
                if let deletedATodo: Todo = response.data,
                   let deletedTodoId: Int = deletedATodo.id {
                    
                    // 삭제된 아이템 찾아서 그 데이터만 현재 리스트에서 빼기
                    let filteredTodos: [Todo] = self.todos.value.filter { (todo: Todo) -> Bool in
                        return (todo.id ?? 0) != deletedTodoId
                    }
                    
                    self.todos.accept(filteredTodos)
                    
//                    self.output.notifyDeleted?()
                    self.output.notifyDeleted.onNext(())
                }
            }).disposed(by: disposeBag)
    }
    
    
    /// 할 일 추가
    /// - Parameters:
    ///   - title: 할일
    fileprivate func addATodo(title: String,
                  isDone: Bool,
                  addedCompletion: @escaping () -> Void) {
        
        if isLoading.value {
            print("로딩중입니다.")
            return
        }
        
        self.isLoading.accept(true)
        
        // 1. 할일 추가 API + 완료된 할일 가져오기 -> Todo[]
        TodosAPI.addATodoAndFetchTodosWithObservable(title: title, isDone: isDone)
            .do(onError: { (failure: Error) in // 1-1. [실패] : 에러처리하기, 로딩완료 처리
                self.isLoading.accept(false)
                self.handleError(failure)
            },onCompleted: { // 1-2. [성공] : 로딩완료 처리, 리프래시 완료 알려주기
                self.isLoading.accept(false)
                self.output.notifyRefreshEnded.onNext(())
                self.fetchRefresh()
            }) // Observable<[Todo]>
                .map { (response: BaseListResponse<Todo>) -> (Meta?, [Todo]?) in
                    return (response.meta, response.data)
                }
                .subscribe(onNext: { (result: (meta: Meta?, todos: [Todo]?)) in
                    guard let pageInfo = result.meta,
                          let fetchedTodos = result.todos else { return }
                    self.todos.accept(fetchedTodos) // 2. 기존 메모리에 있는 데이터 업데이트
                    self.output.notifyTodoAdded.onNext(()) // 3. 아이템 추가되었다고 알리기
                    self.pageInfo.accept(pageInfo) // 4. 페이지 정보 업데이트
                }).disposed(by: disposeBag)

    }
    
    
    /// 할 일 검색
    /// - Parameters:
    ///   - searchTerm: 검색어
    ///   - page: 페이지
    fileprivate func searchTodos(searchTerm: String, page: Int = 1) {
        
        if searchTerm.count < 1 {
            print("검색어가 없음")
            return fetchRefresh()
        }
        
        if isLoading.value {
            print("로딩중입니다")
            return
        }
        
        guard pageInfo.value?.hasNext() ?? true else {
//            return print("다음 페이지 없음")
            return
        }
        
//        self.output.notifySearchDataNotFound?(false)
        self.output.notifySearchDataNotFound.onNext(false)
        
        if page == 1 {
            self.todos.accept([])
        }
        
        isLoading.accept(true)
        
        Observable.just(())
            .delay(RxTimeInterval.milliseconds(700), scheduler: MainScheduler.instance)
            .flatMapLatest{
                TodosAPI
                    .searchTodosWithObservable(searchTerm: searchTerm, page: page)
            }
            .do(onError: { (failure: Error) in
                self.isLoading.accept(false)
                self.handleError(failure)
            }, onCompleted: {
                self.isLoading.accept(false)
                self.output.notifyRefreshEnded.onNext(())
            })
            .compactMap { (response: BaseListResponse<Todo>) -> (meta: Meta?, data: [Todo])? in
                return Optional(tuple: (response.meta, response.data))
            }
            .subscribe(onNext: { pageInfo, fetchedTodos in
                if page == 1 {
                    self.todos.accept(fetchedTodos)
                    } else {
                        let addedTodos = self.todos.value + fetchedTodos
                        
                        self.todos.accept(addedTodos)
                    }
                self.pageInfo.accept(pageInfo)
            }).disposed(by: disposeBag)

    }
    
    /// 데이터 리프레시
    fileprivate func fetchRefresh() {
        self.fetchTodos(page: 1)
    }
    
    /// 더 가져오기
    fileprivate func fetchMore() {
        
        guard let pageInfo: Meta = self.pageInfo.value,
                pageInfo.hasNext(),
              !isLoading.value else {
//            return print("다음 페이지가 없습니다")
            return
        }
        
        if searchTerm.value.count > 0 { // 검색어가 있으면
            self.searchTodos(searchTerm: searchTerm.value, page: self.currentPage.value + 1)
        } else {
            self.fetchTodos(page: currentPage.value + 1)
        }
    }
    
    /// 할 일 가져오기
    /// - Parameter page: 페이지
    func fetchTodos(page: Int = 1, isDone: Bool = false) {
        print(#fileID, #function, #line, "- comment")
        
        if isLoading.value {
            print("로딩중입니다")
            return
        }
        
        isLoading.accept(true)
        
        // 딜레이 주기
        Observable.just(())
            .delay(RxTimeInterval.milliseconds(700), scheduler: MainScheduler.instance)
            .flatMapLatest{
                TodosAPI
                    .fetchTodosWithObservable(page: page)
            }
            .do(onError: { error in
                self.pageInfo.accept(nil)
                self.handleError(error)
            }, onCompleted: {
                self.isLoading.accept(false)
                self.output.notifyRefreshEnded.onNext(())
            })
            .compactMap { (response: BaseListResponse<Todo>) -> (meta: Meta?, data: [Todo])? in
                return Optional(tuple: (response.meta, response.data))
            }
            .subscribe(onNext: { pageInfo, fetchedTodos in
                // 페이지 갱신
                if page == 1 {
                    self.todos.accept(fetchedTodos)
                } else {
                    let addedTodos = self.todos.value + fetchedTodos
                    
                    self.todos.accept(addedTodos)
                }
                self.pageInfo.accept(pageInfo)
            }).disposed(by: disposeBag)
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
//            self.output.notifySearchDataNotFound?(true)
            self.output.notifySearchDataNotFound.onNext(true)
        case .unauthorizedError:
            print("인증 안됨")
        case .decodingError:
            print("디코딩 에러")
        case .errorResponseFromServer:
            print("서버에서 온 에러: \(apiError.info)")
//            self.output.notifyErrorOccured?(apiError.info)
            self.output.notifyErrorOccured.onNext(apiError.info)
        default:
            print("default")
            
        }
    }// handleError
    
}
