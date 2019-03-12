//
//  PaginationPendingTableViewCell.swift
//  foodie
//
//  Created by Austin Du on 2019-01-31.
//  Copyright © 2019 JAY. All rights reserved.
//

import UIKit

class PaginationPendingTableViewCell: UITableViewCell {

    let spinner = UIActivityIndicatorView(style: .gray)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildComponents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        buildComponents()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        spinner.startAnimating()
    }
    
    private func buildComponents() {
        selectionStyle = .none
        spinner.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(spinner)
        contentView.applyAutoLayoutInsetsForAllMargins(to: spinner, with: UIEdgeInsets(top: 10, left: 50, bottom: 10, right: 50))
        spinner.startAnimating()
    }

}
