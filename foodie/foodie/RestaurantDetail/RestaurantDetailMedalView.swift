//
//  RestaurantDetailMedalView.swift
//  foodie
//
//  Created by Austin Du on 2018-05-31.
//  Copyright © 2018 JAY. All rights reserved.
//

import UIKit

class RestaurantDetailMedalView: UIView {
    
    weak var medal: RestaurantMedal?
    var nameLabel: UILabel = UILabel()
    var medalImage: UIImageView = UIImageView()
    var descriptionLabel: UILabel = UILabel()

    internal required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    init(medal: RestaurantMedal) {
        super.init(frame: CGRect(x: 0, y: 0, width: 375, height: 90))
        self.medal = medal
        setup()
    }
    
    private func setup() {
        buildComponents()
    }
    
    private func buildComponents() {
        // name label
        nameLabel.attributedText = NSAttributedString(string: medal?.name ?? "",
                                                      attributes:[ NSAttributedStringKey.kern: 1.5])
        nameLabel.numberOfLines = 2
        nameLabel.textColor = UIColor.ccOchre
        nameLabel.font = UIFont(font: .helveticaNeueMedium, size: 12.0)
        nameLabel.textAlignment = .center
        
        // description label
        descriptionLabel.text = medal?.description
        descriptionLabel.textColor = UIColor.ccOchre
        descriptionLabel.font = UIFont(font: .helveticaNeueLight, size: 12.0)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        
        // medal label
        medalImage.image = medal?.img
        medalImage.contentMode = .scaleAspectFit
        
        // self constraints
        self.heightAnchor.constraint(equalToConstant: 85.0).isActive = true
        
        // stackview construct
        let stackView: UIStackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 15.0
        self.addSubview(stackView)
        
        // stackview constraints
        self.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: stackView.trailingAnchor).isActive = true
        self.topAnchor.constraint(equalTo: stackView.topAnchor, constant: -40.0).isActive = true
        self.bottomAnchor.constraint(equalTo: stackView.bottomAnchor).isActive = true
        
        // left construct
        let leftContainerView: UIView = UIView()
        leftContainerView.addSubview(nameLabel)
        leftContainerView.addSubview(medalImage)
        
        // left container view and its subviews constraints
        leftContainerView.bottomAnchor.constraint(equalTo: medalImage.bottomAnchor).isActive = true
        leftContainerView.leadingAnchor.constraint(equalTo: medalImage.leadingAnchor).isActive = true
        leftContainerView.trailingAnchor.constraint(equalTo: medalImage.trailingAnchor).isActive = true
        leftContainerView.widthAnchor.constraint(equalToConstant: 120.0).isActive = true
        leftContainerView.heightAnchor.constraint(equalToConstant: 45.0)
        medalImage.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: -5).isActive = true
        nameLabel.centerXAnchor.constraint(equalTo: leftContainerView.centerXAnchor).isActive = true
        nameLabel.widthAnchor.constraint(equalToConstant: 55.0).isActive = true
        
        // separator construct
        let middleContainerView: UIView = UIView()
        let line: UIView = UIView()
        line.backgroundColor = UIColor.ccOchre
        middleContainerView.addSubview(line)
        
        // separate constaints
        middleContainerView.widthAnchor.constraint(equalToConstant: 0.25).isActive = true
        middleContainerView.centerYAnchor.constraint(equalTo: line.centerYAnchor).isActive = true
        middleContainerView.centerXAnchor.constraint(equalTo: line.centerXAnchor).isActive = true
        line.widthAnchor.constraint(equalTo: middleContainerView.widthAnchor).isActive = true
        line.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        
        
        // right construct
        let rightContainerView: UIView = UIView()
        rightContainerView.addSubview(descriptionLabel)
        
        // right container view and its subviews constraints
        rightContainerView.centerYAnchor.constraint(equalTo: descriptionLabel.centerYAnchor).isActive = true
        rightContainerView.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor).isActive = true
        rightContainerView.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor).isActive = true
        
        stackView.addArrangedSubview(leftContainerView)
        stackView.addArrangedSubview(middleContainerView)
        stackView.addArrangedSubview(rightContainerView)
        
        // boilerplate
        stackView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        medalImage.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        line.translatesAutoresizingMaskIntoConstraints = false
        leftContainerView.translatesAutoresizingMaskIntoConstraints = false
        middleContainerView.translatesAutoresizingMaskIntoConstraints = false
        rightContainerView.translatesAutoresizingMaskIntoConstraints = false
    }
    
}
