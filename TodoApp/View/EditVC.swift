//
//  EditVC.swift
//  TodoApp
//
//  Created by 김도훈 on 2023/06/22.
//

import UIKit

class EditVC: UIViewController {

    @IBOutlet weak var editTextField: UITextField!
    
    @IBOutlet weak var isDoneSwitch: UISwitch!
    
    @IBOutlet weak var editButton: UIButton!
    
    var todosVM: TodosVM? = nil
    
    var todoTableViewCell: TodoTableViewCell? = nil
    
    var selectedTodo: Todo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editTextField.text = selectedTodo?.title
        
        #warning("현재 데이터 완료 상태에 따라 스위치 on / off 상태 나타내야 함")
        
        editButton.addTarget(self, action: #selector(editTodosButtonTapped), for: .touchUpInside)
        
        // 에러 발생시
        self.todosVM?.notifyErrorOccured = { [weak self] errMsg in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.showErrorAlert(errMsg: errMsg)
            }
        }

    }

    @IBAction func backBtn(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
}

extension EditVC {
    
    @objc func editTodosButtonTapped() {
        
        guard let id = self.selectedTodo?.id else { return }
        
        let editedTitle = editTextField.text ?? ""
        
        let isDoneValue = isDoneSwitch.isOn
        
        self.todosVM?.editATodo(id, editedTitle, isDoneValue, editedCompletion: {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
        })
    }
    
    //MARK: - 에러 얼럿
    @objc func showErrorAlert(errMsg: String) {
        let alert = UIAlertController(title: "안내", message: errMsg, preferredStyle: .alert)
        
        let closeAction = UIAlertAction(title: "닫기", style: .cancel)
        
        alert.addAction(closeAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}
