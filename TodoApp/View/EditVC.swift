//
//  EditVC.swift
//  TodoApp
//
//  Created by 김도훈 on 2023/06/22.
//

import UIKit
import RxSwift
import RxRelay

class EditVC: UIViewController {

    @IBOutlet weak var editTextField: UITextField!
    
    @IBOutlet weak var isDoneSwitch: UISwitch!
    
    @IBOutlet weak var editButton: UIButton!
    
    var todosVM_Closure: TodosVM_Closure? = nil
    
    var todosVM_Rx: TodosVM_Rx? = nil
    
    var disposeBag = DisposeBag()
    
    var todoTableViewCell: TodoTableViewCell? = nil
    
    var selectedTodo: Todo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editTextField.text = selectedTodo?.title
        
        
        editButton.addTarget(self, action: #selector(editTodosButtonTapped), for: .touchUpInside)
        
//        if selectedTodo?.isDone == true {
//            isDoneSwitch.isOn = true
//        } else {
//            isDoneSwitch.isOn = false
//        }
        
        isDoneSwitch.isOn = selectedTodo?.isDone == true ? true : false
        
        // 에러 발생시
        self.todosVM_Rx?
            .notifyErrorOccured
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { editVC, errMsg in
                self.showErrorAlert(errMsg: errMsg)
            }).disposed(by: disposeBag)
        
//        self.todosVM?.output.notifyErrorOccured = { [weak self] errMsg in
//            guard let self = self else { return }
//            DispatchQueue.main.async {
//                self.showErrorAlert(errMsg: errMsg)
//            }
//        }

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
        
//        self.todosVM?.editATodo(id, editedTitle, isDoneValue, editedCompletion: {
//            DispatchQueue.main.async {
//                self.dismiss(animated: true)
//            }
//        })
        
//        self.todosVM?.handleInputAction(action: .editATodo(id, editedTitle, isDoneValue))
        self.todosVM_Rx?.handleInputAction(action: .editATodo(id, editedTitle, isDoneValue))
        
        self.dismiss(animated: true)
    }
    
    //MARK: - 에러 얼럿
    @objc func showErrorAlert(errMsg: String) {
        let alert = UIAlertController(title: "안내", message: errMsg, preferredStyle: .alert)
        
        let closeAction = UIAlertAction(title: "닫기", style: .cancel)
        
        alert.addAction(closeAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}
