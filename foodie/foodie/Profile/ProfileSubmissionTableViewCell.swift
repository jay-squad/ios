//
//  ProfileDishSubmissionTableViewCell.swift
//  foodie
//
//  Created by Austin Du on 2019-01-10.
//  Copyright © 2019 JAY. All rights reserved.
//

import UIKit

protocol ProfileSubmissionTableViewCellDelegate: class {
    func onResubmitButtonTapped(submission: Submission?)
}

class ProfileSubmissionTableViewCell: UITableViewCell {
    
    let kTitleFontSize: CGFloat = 18
    let kDefaultFontSize: CGFloat = 14
    let kDefaultPadding: CGFloat = 16
    let kMaximumLineHeight: CGFloat = 16
    let kCellHeight: CGFloat = 180
    let kImageWidth: CGFloat = 120
    let dishDescriptionParagraphStyle = NSMutableParagraphStyle()
    
    lazy var dishImageView = UIImageView()
    lazy var dishNameLabel = UILabel()
    lazy var dishRestaurantLabel = UILabel()
    lazy var dishPriceLabel = UILabel()
    lazy var dishDescriptionLabel = UILabel()
    lazy var dishApprovalStatusLabel = UILabel()
    lazy var dishResubmitButton = UIButton(type: .custom)

    var submission: Submission?
    
    weak var delegate: ProfileSubmissionTableViewCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildComponents()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        buildComponents()
    }

    func configureCell(submission: Submission?) {
        if let submission = submission {
            self.submission = submission
            
            dishNameLabel.text = nil
            dishRestaurantLabel.text = nil
            dishPriceLabel.text = nil
            dishDescriptionLabel.text = nil
            setDishApprovalStatusLabel(status: .error)
            
            if let dish = submission.dish {
                updateCellWithDish(dish: dish, submission: submission)
                
            }
            
            dishImageView.image = nil
            if let dishImage = submission.dishImage {
                if submission.dish == nil {
                    if let restaurantId = dishImage.restaurantId {
                        NetworkManager.shared.getRestaurantMenu(restaurantId: restaurantId) { (json, _, _) in
                            if let menuJSONs = json {
                                let menu = Menu(json: menuJSONs)
                                if let dish = menu.getDish(id: dishImage.dishId) {
                                    self.submission?.dish = dish
                                    self.submission?.dish?.dishImages = [dishImage]
                                    self.updateCellWithDish(dish: dish, submission: submission)
                                }
                            }
                        }
                    }
                } else {
                    self.submission?.dish?.dishImages = [dishImage]
                }
                if let imageUrl = dishImage.image {
                    dishImageView.sd_setImage(with: URL(string: imageUrl))
                }
            }
        }
    }
    
    private func updateCellWithDish(dish: Dish, submission: Submission) {
        dishNameLabel.text = dish.name
        
        dishRestaurantLabel.text = " "
        // grab restaurant data if needed
        if self.submission?.restaurant == nil {
            NetworkManager.shared.getRestaurant(restaurantId: dish.restaurantId) { (json, _, _) in
                if let restaurantJSON = json {
                    self.submission?.restaurant = Restaurant(json: restaurantJSON)
                    DispatchQueue.main.async {
                        self.dishRestaurantLabel.text = self.submission?.restaurant?.name
                    }
                }
            }
        } else {
            self.dishRestaurantLabel.text = self.submission?.restaurant?.name
        }
        
        dishPriceLabel.text = String(format: "$ %.2f", dish.price)
        
        let descriptionLabelAttributedString = NSMutableAttributedString(string: dish.description,
                                                                         attributes: [.paragraphStyle: dishDescriptionParagraphStyle,
                                                                                      .kern: -0.5])
        dishDescriptionLabel.attributedText = descriptionLabelAttributedString
        
        setDishApprovalStatusLabel(status: getApprovalStatus(submission: submission))
    }
    
    private func setRestaurantInformation() {
        
    }
    
    private func setDishInformation() {
        
    }
    
    private func setDishImageInformation() {
        
    }
    
    private func setMenuSectionInformation() {
        
    }

    private func buildComponents() {
        selectionStyle = .none

        contentView.backgroundColor = UIColor.cc253UltraLightGrey
        contentView.clipsToBounds = false

        dishNameLabel.font = UIFont(font: .helveticaNeueBold, size: kTitleFontSize)
        dishNameLabel.textColor = .cc45DarkGrey
        dishNameLabel.numberOfLines = 2
        dishNameLabel.translatesAutoresizingMaskIntoConstraints = false
        dishNameLabel.text = " "
        dishRestaurantLabel.font = UIFont(font: .helveticaNeue, size: kDefaultFontSize)
        dishRestaurantLabel.textColor = .cc45DarkGrey
        dishRestaurantLabel.numberOfLines = 1
        dishRestaurantLabel.translatesAutoresizingMaskIntoConstraints = false
        dishRestaurantLabel.text = " "
        dishPriceLabel.font = UIFont(font: .helveticaNeue, size: kDefaultFontSize)
        dishPriceLabel.textColor = .cc45DarkGrey
        dishPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        dishPriceLabel.text = " "
        dishDescriptionLabel.font = UIFont(font: .avenirBook, size: kDefaultFontSize)
        dishDescriptionLabel.textColor = .ccGreyishBrown
        dishDescriptionLabel.numberOfLines = 2
        dishDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        dishDescriptionLabel.text = " "
        dishDescriptionParagraphStyle.lineSpacing = 0
        dishDescriptionParagraphStyle.maximumLineHeight = kMaximumLineHeight
        dishApprovalStatusLabel.font = UIFont(font: .helveticaNeue, size: kDefaultFontSize)
        dishApprovalStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        dishApprovalStatusLabel.text = " "
        
        dishResubmitButton.setImage(UIImage(named: "btn_retry"), for: .normal)
        dishResubmitButton.addTarget(self, action: #selector(onResubmitButtonTapped(_:)), for: .touchUpInside)

        let externalContainerView = UIView()
        externalContainerView.translatesAutoresizingMaskIntoConstraints = false
        externalContainerView.clipsToBounds = false
        externalContainerView.backgroundColor = UIColor.white

        contentView.addSubview(externalContainerView)
        externalContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        externalContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        externalContainerView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        externalContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true

        let horizontalStackView = UIStackView()
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        externalContainerView.addSubview(horizontalStackView)
        horizontalStackView.leadingAnchor.constraint(equalTo: externalContainerView.leadingAnchor).isActive = true
        horizontalStackView.trailingAnchor.constraint(equalTo: externalContainerView.trailingAnchor).isActive = true
        horizontalStackView.topAnchor.constraint(equalTo: externalContainerView.topAnchor).isActive = true
        horizontalStackView.bottomAnchor.constraint(equalTo: externalContainerView.bottomAnchor).isActive = true
        horizontalStackView.heightAnchor.constraint(equalToConstant: kCellHeight).isActive = true

        horizontalStackView.addArrangedSubview(dishImageView)
        dishImageView.contentMode = .scaleAspectFill
        dishImageView.widthAnchor.constraint(equalToConstant: kImageWidth).isActive = true
        dishImageView.clipsToBounds = true

        let verticalStackView = UIStackView()
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView.axis = .vertical
        verticalStackView.layoutMargins = UIEdgeInsets(top: kDefaultPadding, left: kDefaultPadding, bottom: kDefaultPadding, right: kDefaultPadding)
        verticalStackView.isLayoutMarginsRelativeArrangement = true
        verticalStackView.spacing = 4.0

        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false

        verticalStackView.addArrangedSubview(dishNameLabel)
        verticalStackView.addArrangedSubview(dishRestaurantLabel)
        verticalStackView.addArrangedSubview(dishPriceLabel)
        verticalStackView.addArrangedSubview(dishDescriptionLabel)
        verticalStackView.addArrangedSubview(spacer)
        verticalStackView.addArrangedSubview(dishApprovalStatusLabel)
        
        contentView.addSubview(dishResubmitButton)
        dishResubmitButton.translatesAutoresizingMaskIntoConstraints = false
        dishResubmitButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        dishResubmitButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        dishResubmitButton.widthAnchor.constraint(equalToConstant: 45).isActive = true
        dishResubmitButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        dishResubmitButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        dishResubmitButton.isHidden = true

        horizontalStackView.addArrangedSubview(verticalStackView)

    }

    private func setDishApprovalStatusLabel(status: Metadata.ApprovalStatus) {
        var labelString = ""
        var labelColour = UIColor.cc74MediumGrey

        switch status {
        case .approved:
            labelString = "approved"
            labelColour = .ccMoneyGreen
            dishResubmitButton.isHidden = true
        case .rejected:
            labelString = "not approved"
            labelColour = .ccErrorRed
            dishResubmitButton.isHidden = false
        case .pending:
            labelString = "pending approval"
            labelColour = .ccPendingBlue
            dishResubmitButton.isHidden = true
        default:
            labelString = ""
            dishResubmitButton.isHidden = true
        }
        dishApprovalStatusLabel.text = labelString
        dishApprovalStatusLabel.textColor = labelColour
    }
    
    private func getApprovalStatus(submission: Submission) -> Metadata.ApprovalStatus {
        return submission.metadata?.approvalStatus ?? .error
    }
    
    @objc private func onResubmitButtonTapped(_ sender: UIButton) {
        delegate?.onResubmitButtonTapped(submission: submission)
    }
}
