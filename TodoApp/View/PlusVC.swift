//
//  PlusViewController.swift
//  TodoApp
//
//  Created by 김도훈 on 2023/06/08.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay

class PlusVC: UIViewController {
        
    @IBOutlet weak var plusTodos: UITextField!
    
    @IBOutlet weak var plusTodosButton: UIButton!
    
    @IBOutlet weak var isDoneSwitch: UISwitch!
    
    var todoTableViewCell: TodoTableViewCell? = nil
    
    var todosVM_Closure: TodosVM_Closure? = nil
    
    var todosVM_Rx: TodosVM_Rx? = nil
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.plusTodosButton.addTarget(self, action: #selector(plusTodosButtonTapped), for: .touchUpInside)
        
        self.isDoneSwitch.setOn(false, animated: true)
        
        // 에러 발생 시
        self.todosVM_Rx?
            .output
            .notifyErrorOccured
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { plusVC, errMsg in
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

extension PlusVC {
    
    //MARK: - 완료 버튼 셀렉터
    @objc func plusTodosButtonTapped() {
        let title: String = plusTodos.text ?? ""
    
        let isDoneValue: Bool = isDoneSwitch.isOn
//        self.todosVM?.addATodo(title: title,
//                               isDone: isDoneValue,
//                               addedCompletion: {
//            DispatchQueue.main.async {
//                if self.isDoneSwitch.isOn {
//                    self.todoTableViewCell?.isCheckedFunc()
//                } else {
//                    self.todoTableViewCell?.isUnCheckedFunc()
//                }
//                self.dismiss(animated: true)
//            }
//        })
        
//        self.todosVM?.handleInputAction(action: .addATodo(title: title, isDone: isDoneValue))
        self.todosVM_Rx?.handleInputAction(action: .addATodo(title: title, isDone: isDoneValue))
        
        if self.isDoneSwitch.isOn {
            self.todoTableViewCell?.isCheckedFunc()
        } else {
            self.todoTableViewCell?.isUnCheckedFunc()
        }
        self.dismiss(animated: true)
    }
    
    //MARK: - 에러 얼럿
    @objc func showErrorAlert(errMsg: String) {
        let alert: UIAlertController = UIAlertController(title: "안내", message: errMsg, preferredStyle: .alert)
        
        let closeAction: UIAlertAction = UIAlertAction(title: "닫기", style: .cancel)
        
        alert.addAction(closeAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
}
