//
//  TodoCelll.swift
//  TodoApp
//
//  Created by 김도훈 on 2023/06/23.
//

import UIKit

class TodoTableViewCell: UITableViewCell {

    @IBOutlet weak var todosDate: UILabel!
    @IBOutlet weak var todosDetail: UILabel!
    @IBOutlet weak var todosTime: UILabel!
    
    @IBOutlet weak var todosId: UILabel!
    
    @IBOutlet weak var checkBoxButton: UIButton!
    
    var isChecked: Bool = false
    
    var cellData: Todo? = nil
    
    var checkButtonClicked: ((_ cellData: Todo, _ checked: Bool) -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        checkBoxButton.addTarget(self, action: #selector(checkBoxToggled), for: .touchUpInside)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func isCheckedFunc() {
        let image = UIImage(named: "checkbox_checked")
        checkBoxButton?.setImage(image, for: .normal)
        todosDetail?.attributedText = todosDetail.text?.strikeThrough()
        
    }
    
    func isUnCheckedFunc() {
        let image = UIImage(named: "checkbox_unchecked")
        checkBoxButton?.setImage(image, for: .normal)
        todosDetail?.attributedText = todosDetail.text?.removeStrikeThrough()
    }
    
    @objc func checkBoxToggled() {
        
        let toBeUpdatedIsDone = cellData?.isDone ?? false
        
        guard let cellData = cellData else { return }
        
        checkButtonClicked?(cellData, !toBeUpdatedIsDone)
        
        if isChecked == false {
            isChecked = true
            
            isCheckedFunc()
            
        } else if isChecked == true {
            isChecked = false
            
            isUnCheckedFunc()            
        }
    }
    
    
    /// 셀데이터 적용
    /// - Parameter cellData:
    func updateUI(_ cellData: Todo) {
        
        guard let id: Int = cellData.id,
              let title: String = cellData.title,
              let updated: String = cellData.updatedAt,
              let isDone: Bool = cellData.isDone
        else {
            print("id, title 없음")
            return
        }
        
        self.cellData = cellData
        
        // 입력(최종 수정) 날짜
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        
        if let date = dateFormatter.date(from: updated) {
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: date)
            self.todosDate?.text = dateString
        } else {
            print("코딩이 잘못 됨")
            self.todosDate?.text = ""
        }
        
        // 아이디
        self.todosId?.text = "\(id)"
        
        // 입력한 TODO
        self.todosDetail?.text = title
        
        // 입력한 시간
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        
        if let time = timeFormatter.date(from: updated) {
            timeFormatter.dateFormat = "HH:mm a"
            let timeString = timeFormatter.string(from: time)
            self.todosTime?.text = timeString
        } else {
            print("코딩이 잘못 됨")
            self.todosTime?.text = ""
        }
        
        // 완료 미완료 여부
        if isDone == true {
            self.isCheckedFunc()
            
        } else {
            self.isUnCheckedFunc()
        }
    }
    
}

//MARK: - label 취소선
extension String {
    func strikeThrough() -> NSAttributedString {
        let attributeString = NSMutableAttributedString(string: self)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0, attributeString.length))
        return attributeString
    }
    
    func removeStrikeThrough() -> NSAttributedString {
        let attributeString = NSMutableAttributedString(string: self)
        attributeString.removeAttribute(NSAttributedString.Key.strikethroughStyle, range: NSMakeRange(0, attributeString.length))
        return attributeString
    }

    
}
