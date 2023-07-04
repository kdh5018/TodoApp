//
//  ViewController.swift
//  TodoApp
//
//  Created by 김도훈 on 2023/06/08.
//

import UIKit

class MainVC: UIViewController {

    @IBOutlet weak var myTableView: UITableView!

    var todosVM: TodosVM = TodosVM()
    
    var todos: [Todo] = []
    
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
        self.todosVM.notifyTodosChanged = { [weak self] updateTodos in
            guard let self = self else { return }
            self.todos = updateTodos
            DispatchQueue.main.async {
                self.myTableView.reloadData()
            }
        }
        
        // 페이지 변경
        self.todosVM.notifyCurrentPageChanged = { [weak self] currentPage in
            guard let self = self else { return }
            DispatchQueue.main.async {
                print("페이지: \(currentPage)")
            }
        }
        
        // 로딩중 여부
        self.todosVM.notifyLoadingStateChanged = { [weak self] isLoading in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if isLoading {
                    self.myTableView.tableFooterView = self.bottomIndicator
                } else {
                    self.myTableView.tableFooterView = nil
                }
            }
        }
        
        // 당겨서 새로고침 완료
        self.todosVM.notifyRefreshEnded = { [weak self]  in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        }
        
        
    }// viewDidLoad


}

//MARK: - 액션들
extension MainVC {
    
    /// 리프레시 처리
    /// - Parameter sender:
    @objc fileprivate func handleRefresh(_ sender: UIRefreshControl) {
        // 뷰모델한테 시키기
        self.todosVM.fetchRefresh()
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
                    #warning("검색 API 호출하기")
                    // 뷰모델 검색어 갱신
                    self.todosVM.searchTerm = userInput
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
//
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
        
        return cell
    }

}

extension MainVC: UITableViewDelegate {
    
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
    
    
    //MARK: - 테이블뷰셀 좌우 스와이프
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // 왼쪽
        let edit = UIContextualAction(style: .normal, title: "수정") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            #warning("sender는 수정해야할 데이터")
            self.performSegue(withIdentifier: "EditVC", sender: nil)
            
            success(true)
        }
        edit.backgroundColor = .systemBlue
        return UISwipeActionsConfiguration(actions: [edit])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // 오른쪽
        let delete = UIContextualAction(style: .normal, title: "삭제") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            print("삭제 클릭 됨")
            #warning("삭제버튼 클릭하면 해당하는 아이디 내용 삭제되어야 함")
            
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
            print("바닥")
            self.todosVM.fetchMore()
        }
    }
}

