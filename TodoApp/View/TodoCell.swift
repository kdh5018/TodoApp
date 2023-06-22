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

    var cellData: Todo? = nil
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func checkBoxBtnClicked(_ sender: UIButton) {
    }
    
    
    /// 셀데이터 적용
    /// - Parameter cellData: <#cellData description#>
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
        self.todosDate.text = cellData.updatedAt
        
        self.todosDetail.text = cellData.title
        
        #warning("시간만 들어가게 수정")
        self.todosTime.text = cellData.updatedAt
        
    }
    

}
