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
    
    @IBOutlet weak var checkBoxButton: UIButton!
    
    var isChecked: Bool = false
    
    var cellData: Todo? = nil
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        checkBoxButton.addTarget(self, action: #selector(checkBoxToggled), for: .touchUpInside)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    @objc func checkBoxToggled() {
        if isChecked == false {
            isChecked = true
            let image = UIImage(named: "checkbox_checked")
            checkBoxButton.setImage(image, for: .normal)
            todosDetail.attributedText = todosDetail.text?.strikeThrough()
            print("체크")
            
        } else if isChecked == true {
            isChecked = false
            let image = UIImage(named: "checkbox_unchecked")
            checkBoxButton.setImage(image, for: .normal)
            todosDetail.attributedText = todosDetail.text?.removeStrikeThrough()
            print("체크해제")
        }
    }
    
    
    /// 셀데이터 적용
    /// - Parameter cellData: 
    func updateUI(_ cellData: Todo) {
        
        guard let id = cellData.id,
              let title = cellData.title,
              var updated = cellData.updatedAt
        else {
            print("id, title 없음")
            return
        }
        
        self.cellData = cellData
        
        #warning("날짜만 들어가게 수정")
        self.todosDate?.text = cellData.updatedAt
        
        self.todosDetail?.text = cellData.title
        
        #warning("시간만 들어가게 수정")
        self.todosTime?.text = cellData.updatedAt
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
