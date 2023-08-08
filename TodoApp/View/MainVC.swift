//
//  ViewController.swift
//  TodoApp
//
//  Created by 김도훈 on 2023/06/08.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay

class MainVC: UIViewController {

    @IBOutlet weak var myTableView: UITableView!
    
    var todosVM_Closure: TodosVM_Closure = TodosVM_Closure()

    var todosVM_Rx: TodosVM_Rx = TodosVM_Rx()
    var todoTableViewCell: TodoTableViewCell = TodoTableViewCell()
    
    var todos: [Todo] = []
    
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    // 클로저 선언과 동시에 호출(클로저 뒤에 괄호가 선언 동시에 호출하는 법)
    lazy var bottomIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = UIColor.systemBlue
        indicator.startAnimating()
        indicator.frame = CGRect(x: 0, y: 0, width: myTableView.bounds.width, height: 44)
        return indicator
    }()
    
    lazy var refreshControl: UIRefreshControl = {
        
        let refreshControl = UIRefreshControl()
        
        refreshControl.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        refreshControl.attributedTitle = NSAttributedString(string: "당겨서 새로고침")
        refreshControl.addTarget(self, action: #selector(self.handleRefresh(_:)), for: .valueChanged)
        return refreshControl
        // viewDidLoad
        // self.myTableView.refreshControl = refreshControl
    }()
    
    // 검색 결과를 찾지 못했다
    lazy var searchDataNotFoundView: UIView = {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: myTableView.bounds.width, height: 300))
        
        let label = UILabel()
        label.text = "검색 결과를 찾을 수 없습니다🗑️"
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }()
    
    // 더 이상 가져올 데이터가 없음
    lazy var bottomNoMoreDataView: UIView = {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: myTableView.bounds.width, height: 60))
        
        let label = UILabel()
        label.text = "더 이상 가져올 데이터가 없습니다👻"
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }()
    
    var searchTermInputWorkItem: DispatchWorkItem? = nil

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 테이블뷰 설정
        self.myTableView.register(TodoTableViewCell.uinib, forCellReuseIdentifier: TodoTableViewCell.reuseIdentifier)
        
        self.myTableView.rowHeight = UITableView.automaticDimension
        
        self.myTableView.dataSource = self
        self.myTableView.delegate = self
        
        self.myTableView.tableFooterView = bottomIndicator
        self.myTableView.refreshControl = refreshControl
        
        // 서치바 설정
        self.searchBar.searchTextField.addTarget(self, action: #selector(searchTermChanged(_:)), for: .editingChanged)
        
        
        // 뷰모델 이벤트 받기 - 뷰 - 뷰모델 바인딩 - 묶기
        self.rxBindViewModel(viewModel: self.todosVM_Rx)
        
                
    }// viewDidLoad
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let destinationVC = segue.destination as? PlusVC {
            destinationVC.todosVM_Rx = self.todosVM_Rx
            destinationVC.todoTableViewCell = self.todoTableViewCell
            
        }
        if let destinationVC = segue.destination as? EditVC, let editedTodo = sender as? Todo {
            destinationVC.todosVM_Rx = self.todosVM_Rx
            destinationVC.todoTableViewCell = self.todoTableViewCell
            destinationVC.selectedTodo = editedTodo
        }
    }
}


extension MainVC {
    
    //MARK: - 뷰모델 바인딩 관련 VM -> View (Rx)
    private func rxBindViewModel(viewModel: TodosVM_Rx) {
        self.todosVM_Rx
            .todos
            .withUnretained(self) // [weak self] 할 필요 없음
            .observe(on: MainScheduler.instance) // 메인 스케줄러에서 진행
            .subscribe(onNext: { mainVC,updatedTodos in
            mainVC.todos = updatedTodos
            mainVC.myTableView.reloadData()
        }).disposed(by: disposeBag)
        
        // 페이지 변경
        self.todosVM_Rx
            .output
            .notifyCurrentPageChanged
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { mainVC, currentPage in
                print("페이지: \(currentPage)")
            }).disposed(by: disposeBag)
        
        // 로딩중 여부
        self.todosVM_Rx
            .isLoading
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext:  { mainVC, isLoading in
                if isLoading {
                    self.myTableView.tableFooterView = self.bottomIndicator
                } else {
                    self.myTableView.tableFooterView = nil
                }
            }).disposed(by: disposeBag)
        
        // 당겨서 새로고침 완료
        self.todosVM_Rx
            .output
            .notifyRefreshEnded
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { mainVC, _ in
                self.refreshControl.endRefreshing()
            }).disposed(by: disposeBag)
        
        // 검색결과 못찾음
        self.todosVM_Rx
            .output
            .notifySearchDataNotFound
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { mainVC, notFound in
                self.myTableView.backgroundView = notFound ? self.searchDataNotFoundView : nil
            }).disposed(by: disposeBag)
        
        // 다음페이지 존재 여부
        self.todosVM_Rx
            .output
            .notifyHasNextPage
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { mainVC, hasNext in
                self.myTableView.tableFooterView = !hasNext ? self.bottomNoMoreDataView : nil
            }).disposed(by: disposeBag)
        
        // 할일 추가 완료 이벤트
        self.todosVM_Rx
            .output
            .notifyTodoAdded
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { mainVC, _ in
                self.myTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                self.myTableView.reloadData()
            }).disposed(by: disposeBag)
        
        // 5. 체크 여부를 알고 서버와 연동시키기 위한 바인딩 설정
        self.todosVM_Rx
            .output
            .notifyTodoCheckChanged
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { mainVC, data in
                let (id, checked) = data
                
                guard let foundIndex = self.todos.firstIndex(where: { $0.id == id }) else {
                    return
                }
                
                self.todos[foundIndex].isDone = checked
                
                let foundIndexPath = IndexPath(row: foundIndex, section: 0)
                
                self.myTableView.reloadRows(at: [foundIndexPath], with: .none)
                
            }).disposed(by: disposeBag)
        

    }
    
    //MARK: - 뷰모델 바인딩 관련 VM -> View (Closure)
    // 뷰모델에서 결과로 나온 애들
    private func bindViewModel(viewModel: TodosVM_Closure) {

//        viewModel.output.notifyTodosChanged = { [weak self] updateTodos in
//            guard let self = self else { return }
//            self.todos = updateTodos
//            DispatchQueue.main.async {
//                self.myTableView.reloadData()
//            }
//        }
        
        // 페이지 변경
//        viewModel.output.notifyCurrentPageChanged = { [weak self] currentPage in
//            guard let self = self else { return }
//            DispatchQueue.main.async {
//                print("페이지: \(currentPage)")
//            }
//        }
        
        // 로딩중 여부
//        viewModel.output.notifyLoadingStateChanged = { [weak self] isLoading in
//            guard let self = self else { return }
//            DispatchQueue.main.async {
//                if isLoading {
//                    self.myTableView.tableFooterView = self.bottomIndicator
//                } else {
//                    self.myTableView.tableFooterView = nil
//                }
//            }
//        }
        
        // 당겨서 새로고침 완료
//        viewModel.output.notifyRefreshEnded = { [weak self]  in
//            guard let self = self else { return }
//            DispatchQueue.main.async {
//                self.refreshControl.endRefreshing()
//            }
//        }
        
        // 검색결과 못찾음
//        viewModel.output.notifySearchDataNotFound = { [weak self] notFound in
//            guard let self = self else { return }
//            DispatchQueue.main.async {
//                self.myTableView.backgroundView = notFound ? self.searchDataNotFoundView : nil
//            }
//        }
        
        // 다음페이지 존재 여부
//        viewModel.output.notifyHasNextPage = { [weak self] hasNext in
//            guard let self = self else { return }
//            DispatchQueue.main.async {
//                self.myTableView.tableFooterView = !hasNext ? self.bottomNoMoreDataView : nil
//            }
//        }
        
        // 할 일 추가 완료 이벤트
//        viewModel.output.notifyTodoAdded = { [weak self] in
//            guard let self = self else { return }
//            DispatchQueue.main.async {
//                self.myTableView?.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
//                self.myTableView?.reloadData()
//            }
//        }
        
        // 5. 체크 여부를 알고 서버와 연동시키기 위한 바인딩 설정
//        viewModel.output.notifyTodoCheckChanged = { [weak self] id, checked in
//            guard let self = self else { return }
//
//            guard let foundIndex = self.todos.firstIndex(where: { $0.id == id }) else {
//                return
//            }
//            // 6. 메모리에 있는 데이터 변경
//            self.todos[foundIndex].isDone = checked
//
//            let foundIndexPath = IndexPath(row: foundIndex, section: 0)
//
//            DispatchQueue.main.async {
//                // 7. UI 변경
//                self.myTableView.reloadRows(at: [foundIndexPath], with: .none)
//            }
//        }

    }
}

//MARK: - 액션들
extension MainVC {
    
    /// 리프레시 처리
    /// - Parameter sender:
    @objc fileprivate func handleRefresh(_ sender: UIRefreshControl) {
        // 뷰모델한테 시키기
//        self.todosVM.fetchRefresh()
//        self.todosVM_Closure.handleInputAction(action: .fetchRefresh)
        self.todosVM_Rx.handleInputAction(action: .fetchRefresh)
    }
    
    /// 검색어 입력
    /// - Parameter sender:
    @objc fileprivate func searchTermChanged(_ sender: UITextField) {
        
        // 검색어가 입력되면 기존 작업 취소
        searchTermInputWorkItem?.cancel()
        
        let dispatchWorkItem = DispatchWorkItem(block: {
            // 백그라운드 - 사용자 입력 userInteractive
            DispatchQueue.global(qos: .userInteractive).async {
                DispatchQueue.main.async { [weak self] in
                    guard let userInput = sender.text,
                          let self = self else { return }
                    
                    print(#fileID, #function, #line, "- 검색 API 호출하기: \(userInput)")
//                    self.todosVM_Closure.todos = []
                    self.todosVM_Rx.todos.accept([])
                    // 뷰모델 검색어 갱신
//                    self.todosVM.searchTerm = userInput
//                    self.todosVM_Closure.handleInputAction(action: .searchTodos(searchTerm: userInput))
                    self.todosVM_Rx.handleInputAction(action: .searchTodos(searchTerm: userInput))
                }
            }
        })
        
        // 기존 작업을 나중에 취소하기 위해 메모리 주소 일치 시켜줌
        self.searchTermInputWorkItem = dispatchWorkItem

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7 , execute: dispatchWorkItem)
    }
    
    
}

extension MainVC: UITableViewDataSource {
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 10
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TodoTableViewCell.reuseIdentifier, for: indexPath) as? TodoTableViewCell else {
            return UITableViewCell()
        }
        
        let cellData = self.todos[indexPath.row]
        
        
        
        // 데이터 셀에 넣어주기
        cell.updateUI(cellData)
        
//        cell.checkButtonClicked = { selectedTodo, checked in
//            self.todosVM.handleToggleTodo(existingTodo: selectedTodo, checked: checked)
//        }
        
        cell.checkButtonClicked = { existingTodo, checked in
//            self.todosVM_Closure.handleInputAction(action: .handleToggleTodo(existingTodo: existingTodo, checked: checked))
            self.todosVM_Rx.handleInputAction(action: .handleToggleTodo(existingTodo: existingTodo, checked: checked))
        }
        
        return cell
    }

}

extension MainVC: UITableViewDelegate {
    
    //MARK: - 테이블뷰셀 좌우 스와이프
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // 왼쪽
        let edit = UIContextualAction(style: .normal, title: "수정") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in

            let itemToEdited = self.todos[indexPath.row]
            
            self.performSegue(withIdentifier: "EditVC", sender: itemToEdited)
            
            success(true)
        }
        edit.backgroundColor = .systemBlue
        return UISwipeActionsConfiguration(actions: [edit])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // 오른쪽
        let delete = UIContextualAction(style: .destructive, title: "삭제") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            print("삭제 클릭 됨")
            
            // 삭제할 아이템을 찾기 위한 indexPath의 값들 찾기
            let itemToDelete = self.todos[indexPath.row]
            print("itemToDelete: \(itemToDelete)")
            
            // 찾은 값들 중 내가 필요한 id만 가져오기
            let id = itemToDelete.id!

//            self.todosVM.deleteATodo(id: id)
//            self.todosVM_Closure.handleInputAction(action: .deleteATodo(id: id))
            self.todosVM_Rx.handleInputAction(action: .deleteATodo(id: id))
            
            success(true)
        }
        delete.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    //MARK: - 스크롤 바닥 감지
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = scrollView.frame.size.height
        let contentYOffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYOffset

        if distanceFromBottom  - 200 < height {
//            self.todosVM.fetchMore()
//            self.todosVM_Closure.handleInputAction(action: .fetchMore)
            self.todosVM_Rx.handleInputAction(action: .fetchMore)
        }
    }
}

//MARK: - 삭제 얼럿
extension MainVC {
    
    @objc func showDeleteAlert(_ id: Int) {
        
        let alert = UIAlertController(title: "할일 삭제", message: "\(id) 할일을 삭제하겠습니까?", preferredStyle: .alert)
        
        let submitAction = UIAlertAction(title: "확인", style: .default, handler: { _ in
//            self.todosVM.deleteATodo(id: id)
//            self.todosVM_Closure.handleInputAction(action: .deleteATodo(id: id))
            self.todosVM_Rx.handleInputAction(action: .deleteATodo(id: id))
        })
        
        let closeAction = UIAlertAction(title: "닫기", style: .cancel)
        
        alert.addAction(submitAction)
        alert.addAction(closeAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}
