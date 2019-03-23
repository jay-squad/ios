//
//  RestaurantDetailMenuExpandedView.swift
//  foodie
//
//  Created by Austin Du on 2019-01-16.
//  Copyright © 2019 JAY. All rights reserved.
//

import UIKit
import ImageSlideshow

class RestaurantDetailMenuExpandedView: UIView {
    
    let kMaximumDescriptionLineHeight: CGFloat = 16
    let kMaximumNameLineHeight: CGFloat = 19
    let dishNameParagraphStyle = NSMutableParagraphStyle()
    let dishDescriptionParagraphStyle = NSMutableParagraphStyle()
    
    let externalContainerView = UIView()
    let dishImageSlideshow = ImageSlideshow()
    let nameLabel = UILabel()
    let priceLabel = UILabel()
    let descriptionLabel = UILabel()
    let tagsLabel = UILabel()
    
    var dish: Dish?
    
    internal required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    func configureView(dish: Dish?) {
        guard let dish = dish else { return }
        self.dish = dish
        let nameLabelAttributedString = NSMutableAttributedString(string: dish.name,
                                                                         attributes: [.paragraphStyle: dishNameParagraphStyle,
                                                                                      .kern: 0])
        nameLabel.attributedText = nameLabelAttributedString
        priceLabel.text = String(format: "$ %.2f", dish.price)
        
        setDescriptionForImage(index: 0)
        
        var inputSources: [InputSource] = []
        for dishImage in dish.dishImages {
            if let imageUrl = dishImage.image, let sdWebImageSource = SDWebImageSource(urlString: imageUrl) {
                inputSources.append(sdWebImageSource)
            }
        }
        dishImageSlideshow.setImageInputs(inputSources)
    }
    
    private func setDescriptionForImage(index: Int) {
        if let dish = self.dish, dish.dishImages.count > index {
            var imageDescription = dish.dishImages[index].description
            let descriptionLabelAttributedString = NSMutableAttributedString(string: imageDescription ?? "",
                                                                             attributes: [.paragraphStyle: self.dishDescriptionParagraphStyle,
                                                                                          .kern: -0.5])
            self.descriptionLabel.attributedText = descriptionLabelAttributedString
        }
    }
    
    func addShadow() {
        externalContainerView.applyDefaultShadow()
    }
    
    private func setup() {
        buildComponents()
    }
    
    private func buildComponents() {
        
        backgroundColor = UIColor.cc253UltraLightGrey
        
        externalContainerView.backgroundColor = .white
        externalContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        let externalStackView = UIStackView()
        externalStackView.translatesAutoresizingMaskIntoConstraints = false
        externalStackView.axis = .vertical
        
        dishImageSlideshow.translatesAutoresizingMaskIntoConstraints = false
        dishImageSlideshow.contentScaleMode = .scaleAspectFill
        dishImageSlideshow.currentPageChanged = { page in
            self.setDescriptionForImage(index: page)
        }
        
        let metadataStackView = UIStackView()
        metadataStackView.translatesAutoresizingMaskIntoConstraints = false
        metadataStackView.layoutMargins = UIEdgeInsets(top: CommonMargins.metadataStackViewHorizonalMargin,
                                                       left: CommonMargins.metadataStackViewHorizonalMargin,
                                                       bottom: 0,
                                                       right: CommonMargins.metadataStackViewHorizonalMargin)
        metadataStackView.isLayoutMarginsRelativeArrangement = true
        metadataStackView.spacing = CommonMargins.metadataStackViewSpacing
        
        metadataStackView.axis = .vertical
        
        let nameAndPriceStackView = UIStackView()
        nameAndPriceStackView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont(font: .helveticaNeueBold, size: 18)
        nameLabel.textColor = UIColor.cc45DarkGrey
        nameLabel.numberOfLines = 2
        dishNameParagraphStyle.lineSpacing = 0
        dishNameParagraphStyle.maximumLineHeight = kMaximumNameLineHeight
        
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.font = UIFont(font: .helveticaNeue, size: 14)
        priceLabel.textColor = UIColor.cc45DarkGrey
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = UIFont(font: .avenirBook, size: 15)
        descriptionLabel.textColor = UIColor.ccGreyishBrown
        descriptionLabel.numberOfLines = 5
        dishDescriptionParagraphStyle.lineSpacing = 0
        dishDescriptionParagraphStyle.maximumLineHeight = kMaximumDescriptionLineHeight
        
        tagsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(externalContainerView)
        externalContainerView.addSubview(externalStackView)
        
        externalStackView.addArrangedSubview(dishImageSlideshow)
        externalStackView.addArrangedSubview(metadataStackView)
        
        metadataStackView.addArrangedSubview(nameAndPriceStackView)
        metadataStackView.addArrangedSubview(descriptionLabel)
        metadataStackView.addArrangedSubview(UIView())
        //        metadataStackView.addArrangedSubview(tagsLabel)
        
        nameAndPriceStackView.addArrangedSubview(nameLabel)
        nameAndPriceStackView.addArrangedSubview(priceLabel)
        nameAndPriceStackView.axis = .vertical
        nameAndPriceStackView.spacing = 0
        nameAndPriceStackView.setContentCompressionResistancePriority(.required, for: .vertical)
        
//        nameAndPriceStackView.heightAnchor.constraint(equalToConstant: 39.0).isActive = true
        
        externalContainerView.applyAutoLayoutInsetsForAllMargins(to: self, with: .zero)
        externalStackView.applyAutoLayoutInsetsForAllMargins(to: externalContainerView, with: .zero)
        
        dishImageSlideshow.widthAnchor.constraint(equalTo: dishImageSlideshow.heightAnchor).isActive = true
        
        // if we want fixed height for the data panel
        //        metadataStackView.heightAnchor.constraint(equalToConstant: 125.0).isActive = true
        
    }
    
}

extension ImageSlideshow {
    override open func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if hitView == self {
            return nil
        } else {
            return hitView
        }
    }
}
