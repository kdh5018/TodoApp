//
//  PlusViewController.swift
//  TodoApp
//
//  Created by 김도훈 on 2023/06/08.
//

import UIKit

class PlusVC: UIViewController {
    
    var mainVC =  MainVC()
    
    var todoTableViewCell = TodoTableViewCell()
    
    var todosVM: TodosVM? = nil
    
    
    @IBOutlet weak var plusTodos: UITextField!
    
    @IBOutlet weak var plusTodosButton: UIButton!
    
    @IBOutlet weak var isDoneSwitch: UISwitch!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.plusTodosButton.addTarget(self, action: #selector(finishInputTodos), for: .touchUpInside)
        
        self.isDoneSwitch.setOn(false, animated: true)
        
        #warning("로그에는 뜨는데 에러 메세지 얼럿 안 뜸")
        // 에러 발생 시
        self.todosVM?.notifyErrorOccured = { [weak self] errMsg in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.showErrorAlert(errMsg: errMsg)
            }
        }
        
    }
    

    
    @IBAction func switchIsDone(_ sender: UISwitch) {
        if isDoneSwitch.isOn {
            #warning("체크박스 체크, 취소선 그어져야 함")
//            let image = UIImage(named: "checkbox_checked")
//            self.todoTableViewCell.checkBoxButton?.setImage(image, for: .normal)
//            self.todoTableViewCell.todosDetail?.attributedText = todoTableViewCell.todosDetail.text?.strikeThrough()
            
//            self.todoTableViewCell.isCheckedFunc()
            
            #warning("api 연동 시 완료로 체크되어야 함")
            
        } else {
            #warning("체크박스 체크 X, 취소선 없어야 함")
//            let image = UIImage(named: "checkbox_unchecked")
//            self.todoTableViewCell.checkBoxButton?.setImage(image, for: .normal)
//            self.todoTableViewCell.todosDetail?.attributedText = todoTableViewCell.todosDetail.text?.removeStrikeThrough()
            
//            self.todoTableViewCell.isUnCheckedFunc()
            
            #warning("api 연동 시 미완료로 체크되어야 함")
            
        }
    }
    
    

    @IBAction func backBtn(_ sender: UIButton) {
        
        self.dismiss(animated: true)
    }
    
    
}

extension PlusVC {
    
    //MARK: - 완료 버튼 셀렉터
    @objc func finishInputTodos() {
        let title = plusTodos.text ?? ""
        
        self.todosVM?.addATodo(title: title,
                               addedCompletion: {
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
