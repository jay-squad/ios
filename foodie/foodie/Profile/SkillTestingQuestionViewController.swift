//
//  SkillTestingQuestionViewController.swift
//  foodie
//
//  Created by Austin Du on 2019-03-22.
//  Copyright © 2019 JAY. All rights reserved.
//

import UIKit
import TextFieldEffects

protocol SkillTestingQuestionViewControllerDelegate: class {
    func onSuccessfulAnswer()
    func onCancel()
}

class SkillTestingQuestionViewController: UIViewController {

    private var question = SkillTestingQuestion.generate()
    private let answerTextfield = HoshiTextField()
    private let questionLabel = UILabel()
    private let answerLabel = UILabel()
    
    weak var delegate: SkillTestingQuestionViewControllerDelegate?

    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        buildComponents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        answerTextfield.becomeFirstResponder()
    }
    
    private func buildComponents() {
        view.backgroundColor = .clear
        let shadowContainerView = UIView()
        shadowContainerView.translatesAutoresizingMaskIntoConstraints = false
        shadowContainerView.layer.shadowColor = UIColor.cc155Grey.cgColor
        shadowContainerView.layer.shadowOpacity = 0.75
        shadowContainerView.layer.shadowRadius = 8
        
        let externalContainerView = UIView()
        externalContainerView.translatesAutoresizingMaskIntoConstraints = false
        externalContainerView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height / 2).isActive = true
        externalContainerView.layer.cornerRadius = 15
        externalContainerView.clipsToBounds = true
        externalContainerView.backgroundColor = .white
        
        view.addSubview(shadowContainerView)
        shadowContainerView.addSubview(externalContainerView)
        shadowContainerView.applyAutoLayoutInsetsForAllMargins(to: externalContainerView, with: .zero)

        view.leadingAnchor.constraint(equalTo: externalContainerView.leadingAnchor, constant: -15).isActive = true
        view.trailingAnchor.constraint(equalTo: externalContainerView.trailingAnchor, constant: 15).isActive = true
        view.topAnchor.constraint(equalTo: externalContainerView.topAnchor, constant: -35).isActive = true
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 15
        
        externalContainerView.addSubview(stackView)
        externalContainerView.applyAutoLayoutInsetsForAllMargins(to: stackView, with: UIEdgeInsets(top: 35, left: 0, bottom: 0, right: 0))
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont(font: .helveticaNeueBold, size: 16)
        titleLabel.textColor = UIColor.cc74MediumGrey
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.text = "To receive your prize, you must answer a skill testing question:"
        
        questionLabel.font = UIFont(font: .helveticaNeueMedium, size: 16)
        questionLabel.textColor = UIColor.cc74MediumGrey
        questionLabel.textAlignment = .center
        questionLabel.text = question.0 + " = ?"
        
        answerLabel.font = UIFont(font: .helveticaNeueMedium, size: 16)
        answerLabel.textColor = UIColor.cc74MediumGrey
        answerLabel.textAlignment = .center
        answerLabel.text = "Your answer:"
        
        answerTextfield.translatesAutoresizingMaskIntoConstraints = false
        answerTextfield.keyboardType = .numbersAndPunctuation
        answerTextfield.autocorrectionType = .no
        answerTextfield.textAlignment = .center
        answerTextfield.heightAnchor.constraint(equalToConstant: 50).isActive = true
        answerTextfield.borderInactiveColor = UIColor.cc45DarkGrey
        answerTextfield.borderActiveColor = UIColor.cc45DarkGrey
        answerTextfield.widthAnchor.constraint(equalToConstant: 150).isActive = true
        
        let spacer1 = UIView()
        spacer1.translatesAutoresizingMaskIntoConstraints = false
        spacer1.heightAnchor.constraint(equalToConstant: 10).isActive = true
        
        let spacer2 = UIView()
        
        let titleLabelContainer = UIView()
        titleLabelContainer.translatesAutoresizingMaskIntoConstraints = false
        titleLabelContainer.addSubview(titleLabel)
        titleLabelContainer.applyAutoLayoutInsetsForAllMargins(to: titleLabel, with: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15))
        
        let answerTextfieldContainer = UIView()
        answerTextfieldContainer.translatesAutoresizingMaskIntoConstraints = false
        answerTextfieldContainer.addSubview(answerTextfield)
        answerTextfieldContainer.topAnchor.constraint(equalTo: answerTextfield.topAnchor).isActive = true
        answerTextfieldContainer.bottomAnchor.constraint(equalTo: answerTextfield.bottomAnchor).isActive = true
        answerTextfieldContainer.centerXAnchor.constraint(equalTo: answerTextfield.centerXAnchor).isActive = true
        
        stackView.addArrangedSubview(titleLabelContainer)
        stackView.addArrangedSubview(spacer1)
        stackView.addArrangedSubview(questionLabel)
        stackView.addArrangedSubview(spacer2)
        stackView.addArrangedSubview(answerLabel)
        stackView.addArrangedSubview(answerTextfieldContainer)
        
        let buttonsStackView = UIStackView()
        buttonsStackView.axis = .horizontal
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        let cancelButton = UIButton()
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(UIColor.cc45DarkGrey, for: .normal)
        cancelButton.titleLabel?.font = UIFont(font: .helveticaNeueBold, size: 16)
        cancelButton.backgroundColor = UIColor.cc240SuperLightGrey
        cancelButton.addTarget(self, action: #selector(onCancelButtonTapped), for: .touchUpInside)
        
        let submitButton = UIButton()
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.setTitle("Submit", for: .normal)
        submitButton.setTitleColor(UIColor.cc253UltraLightGrey, for: .normal)
        submitButton.titleLabel?.font = UIFont(font: .helveticaNeueBold, size: 16)
        submitButton.backgroundColor = UIColor.ccMoneyGreen
        submitButton.addTarget(self, action: #selector(onSubmitButtonTapped), for: .touchUpInside)
        
        buttonsStackView.addArrangedSubview(cancelButton)
        buttonsStackView.addArrangedSubview(submitButton)
        
        submitButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor).isActive = true

        stackView.addArrangedSubview(buttonsStackView)
    }
    
    @objc private func onCancelButtonTapped() {
        answerTextfield.resignFirstResponder()
        delegate?.onCancel()
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func onSubmitButtonTapped() {
        if "\(question.1)" == answerTextfield.text {
            delegate?.onSuccessfulAnswer()
            answerTextfield.resignFirstResponder()
            dismiss(animated: true, completion: nil)
        } else {
            question = SkillTestingQuestion.generate()
            questionLabel.text = question.0 + " = ?"
            answerTextfield.text = nil
            answerLabel.text = "Wrong, try again:"
        }
    }

}
