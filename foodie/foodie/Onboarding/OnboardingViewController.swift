//
//  OnboardingViewController.swift
//  foodie
//
//  Created by Austin Du on 2018-07-05.
//  Copyright © 2018 JAY. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import ActiveLabel
import Crashlytics

class OnboardingViewController: UIViewController {

    var collectionView: UICollectionView! = nil
    var signupButtonTapped = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0),
                                          collectionViewLayout: collectionViewFlowLayout)
        
        setupNibs()
        setupCollectionView()
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        view.topAnchor.constraint(equalTo: collectionView.topAnchor).isActive = true
        view.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor).isActive = true

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if FBSDKAccessToken.currentAccessTokenIsActive() {
            Answers.logSignUp(withMethod: AnswersKeys.onboarding_signup_method_facebook, success: true, customAttributes: nil)
            NetworkManager.shared.setAuthedState()
            self.dismiss(animated: true, completion: nil)
        } else if signupButtonTapped {
            Answers.logSignUp(withMethod: AnswersKeys.onboarding_signup_method_facebook, success: false, customAttributes: nil)
        }
    }
    
    private func setupNibs() {
        collectionView.register(OnboardingCollectionViewCell.self,
                                forCellWithReuseIdentifier: "kOnboardingCollectionViewCellId")
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
    }
    
}

extension OnboardingViewController: UICollectionViewDataSource,
                                    UICollectionViewDelegate,
                                    UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "kOnboardingCollectionViewCellId",
                                                         for: indexPath) as? OnboardingCollectionViewCell {
            cell.configureCell(index: indexPath.section)
            cell.onboardingDelegate = self
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }
    
}

extension OnboardingViewController: OnboardingCollectionViewCellDelegate {
    func onNextButtonTapped(index: Int) {
        if index + 1 == 3 {
            Answers.logSignUp(withMethod: AnswersKeys.onboarding_signup_method_skipped, success: false, customAttributes: nil)
            dismiss(animated: true, completion: nil)
        } else {
            collectionView.scrollToItem(at: IndexPath(item: 0, section: index+1), at: .left, animated: true)
        }
    }
    
    func onSignupButtonTapped(index: Int) {
        signupButtonTapped = true
    }
}

protocol OnboardingCollectionViewCellDelegate: class {
    func onNextButtonTapped(index: Int)
    func onSignupButtonTapped(index: Int)
}

class OnboardingCollectionViewCell: UICollectionViewCell {
    
    let imageView = UIImageView()
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let nextButton = UIButton()
    let signupButton = FacebookButton()
    let legalLabel = FacebookButton.getLegalLabel()
    
    var index: Int?
    weak var onboardingDelegate: OnboardingCollectionViewCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildComponents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        buildComponents()
    }
    
    func configureCell(index: Int) {
        self.index = index
        switch index {
        case 0:
            imageView.image = UIImage(named: "onboarding_1")
            titleLabel.text = "One app,\nmany menus"
            subtitleLabel.text = "Never question what your\nfood will look like ever again."
            signupButton.isHidden = true
            nextButton.setTitle("next", for: .normal)
            legalLabel.isHidden = true
        case 1:
            imageView.image = UIImage(named: "onboarding_2")
            titleLabel.text = "Get points\nfrom meals"
            subtitleLabel.text = "Earn points by simply trying\nnew dishes."
            signupButton.isHidden = true
            nextButton.setTitle("next", for: .normal)
            legalLabel.isHidden = true
        case 2:
            imageView.image = UIImage(named: "onboarding_3")
            titleLabel.text = "Create an\naccount now"
            subtitleLabel.text = "Personalize your experience and\nstart earning rewards."
            nextButton.layer.borderWidth = 0.0
            nextButton.setTitle("skip for now", for: .normal)
            legalLabel.isHidden = false
        default:
            break
        }
    }
    
    private func buildComponents() {
        clipsToBounds = true
        
        let externalContainerView = UIView()
        externalContainerView.translatesAutoresizingMaskIntoConstraints = false
        externalContainerView.backgroundColor = UIColor.cc253UltraLightGrey
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        signupButton.translatesAutoresizingMaskIntoConstraints = false
        legalLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.font = UIFont(font: .helveticaNeueBold, size: 50.0)
        titleLabel.numberOfLines = 2
        subtitleLabel.font = UIFont(font: .helveticaNeueBold, size: 18.0)
        subtitleLabel.numberOfLines = 2
        nextButton.layer.borderColor = UIColor.cc45DarkGrey.cgColor
        nextButton.layer.borderWidth = 1.0
        nextButton.layer.cornerRadius = 8.0
        nextButton.setTitle("next", for: .normal)
        nextButton.setTitleColor(UIColor.cc45DarkGrey, for: .normal)
        nextButton.titleLabel?.font = UIFont(font: .helveticaNeueMedium, size: 18.0)

        nextButton.addTarget(self, action: #selector(onNextButtonTapped), for: .touchUpInside)
        signupButton.addTarget(self, action: #selector(onSignupButtonTapped), for: .touchUpInside)
        
        contentView.addSubview(externalContainerView)
        externalContainerView.addSubview(imageView)
        externalContainerView.addSubview(titleLabel)
        externalContainerView.addSubview(subtitleLabel)
        externalContainerView.addSubview(nextButton)
        externalContainerView.addSubview(signupButton)
        externalContainerView.addSubview(legalLabel)
        
        titleLabel.leadingAnchor.constraint(equalTo: externalContainerView.leadingAnchor, constant: 20).isActive = true
        titleLabel.topAnchor.constraint(equalTo: externalContainerView.topAnchor, constant: 100).isActive = true
        
        subtitleLabel.leadingAnchor.constraint(equalTo: externalContainerView.leadingAnchor,
                                               constant: 20).isActive = true
        subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 22).isActive = true
        
        signupButton.centerXAnchor.constraint(equalTo: nextButton.centerXAnchor).isActive = true
        signupButton.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -20).isActive = true
        
        nextButton.widthAnchor.constraint(equalToConstant: 120.0).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: 45.0).isActive = true
        nextButton.centerXAnchor.constraint(equalTo: externalContainerView.centerXAnchor).isActive = true
        nextButton.bottomAnchor.constraint(equalTo: externalContainerView.bottomAnchor, constant: -135).isActive = true
        
        legalLabel.bottomAnchor.constraint(equalTo: externalContainerView.bottomAnchor, constant: -20).isActive = true
        legalLabel.centerXAnchor.constraint(equalTo: externalContainerView.centerXAnchor).isActive = true
        legalLabel.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 40).isActive = true

        externalContainerView.topAnchor.constraint(equalTo: imageView.topAnchor).isActive = true
        externalContainerView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        externalContainerView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor).isActive = true
        externalContainerView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
        
        externalContainerView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        externalContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        externalContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        externalContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    @objc private func onNextButtonTapped() {
        self.onboardingDelegate?.onNextButtonTapped(index: self.index!)
    }
    
    @objc private func onSignupButtonTapped() {
        self.onboardingDelegate?.onSignupButtonTapped(index: self.index!)
    }
}
