//
//  SpacerTableViewCell.swift
//  foodie
//
//  Created by Austin Du on 2019-03-07.
//  Copyright © 2019 JAY. All rights reserved.
//

import UIKit

let kSpacerTableViewCellId = "SpacerTableViewCellId"

class SpacerTableViewCell: UITableViewCell {
    
    let spacerView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildComponents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        buildComponents()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        buildComponents()
    }
    
    func configureCell(height: CGFloat) {
        spacerView.heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    private func buildComponents() {
        selectionStyle = .none
        contentView.addSubview(spacerView)
        contentView.applyAutoLayoutInsetsForAllMargins(to: spacerView, with: .zero)
    }

}
