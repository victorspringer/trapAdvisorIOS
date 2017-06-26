//
//  TableViewCell.swift
//  trapAdvisor
//
//  Created by Victor Springer on 18/06/17.
//  Copyright © 2017 Victor Springer. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var taLabel: UILabel?
    @IBOutlet weak var locationLabel: UILabel?
    @IBOutlet weak var totalLabel: UILabel?
    @IBOutlet weak var picture: UIImageView?
    @IBOutlet weak var name: UILabel?
    @IBOutlet weak var location: UILabel?
    @IBOutlet weak var total: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
