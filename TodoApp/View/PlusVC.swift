//
//  PlusViewController.swift
//  TodoApp
//
//  Created by 김도훈 on 2023/06/08.
//

import UIKit

class PlusVC: UIViewController {
        
    @IBOutlet weak var plusTodos: UITextField!
    
    @IBOutlet weak var plusTodosButton: UIButton!
    
    @IBOutlet weak var isDoneSwitch: UISwitch!
    
    var todoTableViewCell: TodoTableViewCell? = nil
    
    var todosVM: TodosVM? = nil
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.plusTodosButton.addTarget(self, action: #selector(plusTodosButtonTapped), for: .touchUpInside)
        
        self.isDoneSwitch.setOn(false, animated: true)
        
        // 에러 발생 시
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

extension PlusVC {
    
    //MARK: - 완료 버튼 셀렉터
    @objc func plusTodosButtonTapped() {
        let title = plusTodos.text ?? ""
    
//        guard let isDone = self.todo?.isDone else { return }
        
        self.todosVM?.addATodo(title: title,
                               addedCompletion: {
            DispatchQueue.main.async {
                #warning("체크박스 체크, 취소선 그어져야 함")
                #warning("api 연동 시 완료로 체크되어야 함")
                if self.isDoneSwitch.isOn {
                    self.todoTableViewCell?.isCheckedFunc()
                } else {
                #warning("체크박스 체크 X, 취소선 없어야 함")
                #warning("api 연동 시 미완료로 체크되어야 함")
                    self.todoTableViewCell?.isUnCheckedFunc()
                }
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
