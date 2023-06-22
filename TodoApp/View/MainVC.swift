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
        
        self.myTableView.register(TodoCell.uinib, forCellReuseIdentifier: TodoCell.reuseIdentifier)
        
        self.myTableView.rowHeight = UITableView.automaticDimension
        
        self.myTableView.dataSource = self
        self.myTableView.delegate = self
        
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
        return tableView.rowHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TodoCell.reuseIdentifier, for: indexPath) as? TodoCell else {
            return UITableViewCell()
        }
        
        let cellData = self.todos[indexPath.row]
        
        // 데이터 셀에 넣어주기
        cell.updateUI(cellData)
        
        return cell
    }

}

extension MainVC: UITableViewDelegate {

}

