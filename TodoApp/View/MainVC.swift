//
//  ViewController.swift
//  TodoApp
//
//  Created by 김도훈 on 2023/06/08.
//

import UIKit

class MainVC: UIViewController {

    @IBOutlet weak var myTableView: UITableView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.myTableView.register(TodoCell.uinib, forCellReuseIdentifier: TodoCell.reuseIdentifier)
        
        self.myTableView.dataSource = self
        self.myTableView.delegate = self
        
    }
    
    init() {
        TodosAPI.fetchTodos { result in
            switch result {
            case .success(let todosResponse):
                print("todosVM - todosResponse: \(todosResponse)")
            case .failure(let failure):
                print("todosVM - failure: \(failure)")
            }        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

}

extension MainVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return 1
    }
    
    
}

extension MainVC: UITableViewDelegate {

}

