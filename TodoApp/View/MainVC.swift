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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.myTableView.register(TodoTableViewCell.uinib, forCellReuseIdentifier: TodoTableViewCell.reuseIdentifier)
        
        self.myTableView.rowHeight = UITableView.automaticDimension
        
        self.myTableView.dataSource = self
        self.myTableView.delegate = self
        
        
        // 서비스 로직
        TodosAPI.fetchTodos(page: 1, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                if let fetchedTodos: [Todo] = response.data {
                    self.todos = fetchedTodos
                    DispatchQueue.main.async {
                        self.myTableView.reloadData()
                    }
                }
            case .failure(let failure):
                print("failure: \(failure)")
            }
        })
        
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
        }
    }
}

