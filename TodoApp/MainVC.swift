//
//  ViewController.swift
//  TodoApp
//
//  Created by 김도훈 on 2023/06/08.
//

import UIKit

class MainVC: UIViewController {

    @IBOutlet weak var myTableView: UITableView!
    

    var todos: [Todo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.myTableView.register(TodoCell.uinib, forCellReuseIdentifier: TodoCell.reuseIdentifier)
        
        self.myTableView.dataSource = self
        self.myTableView.delegate = self
        
    }
    
    func fetchTodos(page: Int = 1) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
            TodosAPI.fetchTodos(page: page, completion: { [weak self] result in
                
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    if let fetchedTodos: [Todo] = response.data,
                       let _: Meta = response.meta {
                        if page == 1 {
                            self.todos = fetchedTodos
                        } else {
                            self.todos.append(contentsOf: fetchedTodos)
                        }
                    }
                case .failure(let failure):
                    print("failure")
                }
                
            })
        })
        self.myTableView.reloadData()
    }

    

}

extension MainVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TodoCell.reuseIdentifier, for: indexPath) as? TodoCell else {
            return UITableViewCell()
        }
        
        let cellData = self.todos[indexPath.row]
        
        cell.updateUI(cellData)
        
    
        
        return cell
    }
    
    
}

extension MainVC: UITableViewDelegate {
 
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = scrollView.frame.size.height
        let contentYOffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYOffset

//        if distanceFromBottom - 200 < height {
//            self.todosVM.fetchMore()
//        }
    }

}

