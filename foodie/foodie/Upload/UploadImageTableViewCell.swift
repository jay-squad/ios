//
//  UploadImageTableViewCell.swift
//  foodie
//
//  Created by Austin Du on 2018-06-27.
//  Copyright © 2018 JAY. All rights reserved.
//

import UIKit

class UploadImageTableViewCell: UITableViewCell {

    var uploadImageView = UIImageView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildComponents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        buildComponents()
    }
    
    func configureCell(image: UIImage?) {
        uploadImageView.image = image
    }
    
    private func buildComponents() {
        selectionStyle = .none
        
        let externalContainerView = UIView()
        externalContainerView.translatesAutoresizingMaskIntoConstraints = false
        externalContainerView.backgroundColor = UIColor.cc253UltraLightGrey
        
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.contentMode = .scaleAspectFill
        
        contentView.addSubview(externalContainerView)
        externalContainerView.addSubview(uploadImageView)
        
        uploadImageView.topAnchor.constraint(equalTo: externalContainerView.topAnchor).isActive = true
        uploadImageView.leadingAnchor.constraint(equalTo: externalContainerView.leadingAnchor).isActive = true
        uploadImageView.trailingAnchor.constraint(equalTo: externalContainerView.trailingAnchor).isActive = true
        uploadImageView.bottomAnchor.constraint(equalTo: externalContainerView.bottomAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
        uploadImageView.heightAnchor.constraint(equalTo: uploadImageView.widthAnchor).isActive = true
        
        externalContainerView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        externalContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        externalContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        externalContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2.0).isActive = true
    }
}
