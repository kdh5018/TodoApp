//
//  TodoCell.swift
//  TodoApp
//
//  Created by 김도훈 on 2023/06/12.
//

import UIKit

class TodoCell: UITableViewCell {

    @IBOutlet weak var todosDate: UILabel!
    @IBOutlet weak var todosDetail: UILabel!
    @IBOutlet weak var todosTime: UILabel!
    
    @IBOutlet weak var checkBoxBtn: UIButton!
    
    var cellData: Todo? = nil
    
    let checkedImage = UIImage(named: "checkBox_checked")
    let uncheckedImage = UIImage(named: "checkBox_unchecked")
    
    var isChecked: Bool = false {
        didSet {
            // Update the checkbox image based on the state
            let image = isChecked ? checkedImage : uncheckedImage
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        checkBoxBtn.addTarget(self, action: #selector(checkboxTapped), for: .touchUpInside)
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateUI(_ cellData: Todo) {
        guard let title: String = cellData.title else {
            print("title 없음")
            return
        }
        
        self.cellData = cellData
        
        self.todosDetail.text = title
        
    }

    @objc func checkboxTapped() {
        isChecked = !isChecked
        if isChecked == true {
            todosDetail.attributedText = todosDetail.text?.strikeThrough()
        }
    }
    

}

extension String {
    func strikeThrough() -> NSAttributedString {
        let attributeString = NSMutableAttributedString(string: self)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0, attributeString.length))
        return attributeString
    }
}
