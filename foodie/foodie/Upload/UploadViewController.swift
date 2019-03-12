//
//  UploadViewController.swift
//  foodie
//
//  Created by Austin Du on 2018-06-27.
//  Copyright © 2018 JAY. All rights reserved.
//

import UIKit
import DKImagePickerController
import Photos.PHImageManager
import Validator
import GradientLoadingBar

let kFormComponentTableViewCellId = "FormComponentTableViewCellId"
let kUploadImageTableViewCellId = "UploadImageTableViewCellId"
let kUploadBasicInfoTableViewCellId = "UploadBasicInfoTableViewCellId"
let kAdditionalInfoTableViewCellId = "AdditionalInfoTableViewCellId"
let kUploadEarningsTableViewCellId = "UploadEarningsTableViewCellId"

enum UploadFormError: Error {
    case required
    case price
}

protocol UploadViewControllerDelegate: class {
    func onSuccessfulUpload()
}

class UploadViewController: UIViewController {

    var tableView = UITableView()
    
    var restaurantId: Int = -1
    var restaurantMenu: Menu?
    var uploadImage: UIImage? {
        didSet {
            tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        }
    }
    
    var restaurantResult: ValidationResult?
    var dishResult: ValidationResult?
    var priceResult: ValidationResult?
    
    var prepopulatedSubmission: Submission?
    
    weak var delegate: UploadViewControllerDelegate?
    
    private var estimatedHeightDict: [IndexPath: CGFloat] = [:]
    
    private func setupNibs() {
        tableView.register(FormComponentTableViewCell.self,
                           forCellReuseIdentifier: kFormComponentTableViewCellId)
        tableView.register(UploadImageTableViewCell.self,
                           forCellReuseIdentifier: kUploadImageTableViewCellId)
        tableView.register(UploadBasicInfoTableViewCell.self,
                           forCellReuseIdentifier: kUploadBasicInfoTableViewCellId)
        tableView.register(AdditionalInfoTableViewCell.self,
                           forCellReuseIdentifier: kAdditionalInfoTableViewCellId)
        tableView.register(UploadEarningsTableViewCell.self,
                           forCellReuseIdentifier: kUploadEarningsTableViewCellId)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }
    
    private func setupNavigation() {
        self.setDefaultNavigationBarStyle()
        
        navigationItem.title = "Upload a Dish"
        
        let rightNavBtn = UIBarButtonItem(title: "Submit",
                                         style: .plain,
                                         target: self,
                                         action: #selector(onSubmitButtonTapped(_:)))
        navigationItem.rightBarButtonItem = rightNavBtn
        
    }
    
    func addDismissButton() {
        let leftNavBtn = UIBarButtonItem(title: "Dismiss",
                                          style: .plain,
                                          target: self,
                                          action: #selector(onDismissButtonTapped(_:)))
        navigationItem.leftBarButtonItem = leftNavBtn
    }
    
    @objc private func onSubmitButtonTapped(_ sender: UIBarButtonItem?) {
        if let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? UploadBasicInfoTableViewCell {
            restaurantResult = (cell.dishSectionTextField.text ?? "").validate(rule: Validator.requiredRule)
            dishResult = (cell.dishTextField.text ?? "").validate(rule: Validator.requiredRule)
            priceResult = (cell.priceTextField.text ?? "").validate(rule: Validator.priceRule)
            
            if restaurantResult!.isValid && dishResult!.isValid && priceResult!.isValid {
                
                var description: String?
                if let cell = tableView.cellForRow(at: IndexPath(row: 2, section: 0))
                    as? AdditionalInfoTableViewCell,
                    let desc = cell.additionalNotesTextField.text {
                    description = desc
                }
                
                GradientLoadingBar.shared.show()
                sender?.isEnabled = false
                if uploadImage != nil {
                    NetworkManager.shared.insertMenuItem(restaurantId: restaurantId,
                                                         itemName: cell.dishTextField.text,
                                                         itemImage: uploadImage,
                                                         description: description,
                                                         sectionName: cell.dishSectionTextField.text,
                                                         price: cell.priceFloat) { (_, error, _) in
                                                            GradientLoadingBar.shared.hide()
                                                            if error == nil {
                                                                self.delegate?.onSuccessfulUpload()
                                                                self.navigationController?.popViewController(animated: true)
                                                            } else {
                                                                sender?.isEnabled = true
                                                            }
                    }
                } else {
                    NetworkManager.shared.insertMenuItem(restaurantId: restaurantId,
                                                         itemName: cell.dishTextField.text,
                                                         itemImageUrl: prepopulatedSubmission?.dishImage?.image,
                                                         description: description,
                                                         sectionName: cell.dishSectionTextField.text,
                                                         price: cell.priceFloat) { (_, error, _) in
                                                            GradientLoadingBar.shared.hide()
                                                            if error == nil {
                                                                self.delegate?.onSuccessfulUpload()
                                                                self.navigationController?.popViewController(animated: true)
                                                            } else {
                                                                sender?.isEnabled = true
                                                            }
                    }
                }
                
            } else {
                if !restaurantResult!.isValid {
                    cell.dishSectionTextField.errorStyle()
                }
                if !dishResult!.isValid {
                    cell.dishTextField.errorStyle()
                }
                if !priceResult!.isValid {
                    cell.priceTextField.errorStyle()
                }
            }
        }
    }
    
    @objc private func onDismissButtonTapped(_ sender: UIBarButtonItem?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNibs()
        setupTableView()
        buildComponents()
        setupNavigation()
        hideKeyboardWhenTappedAround()
        shiftViewWhenKeyboardAppears()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide),
                                               name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    private func buildComponents() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.applyAutoLayoutInsetsForAllMargins(to: view, with: .zero)
    }
    
    func prepopulate(_ submission: Submission) {
        prepopulatedSubmission = submission
    }
    
    @objc override func shiftViewKeyboardWillShow(notification: NSNotification) {
        super.shiftViewKeyboardWillShow(notification: notification)
        if viewIsShiftedFromKeyboard() {
            if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? UploadImageTableViewCell {
                cell.isUserInteractionEnabled = false
            }
        }
    }
    
    @objc func keyboardDidHide(notification: NSNotification) {
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? UploadImageTableViewCell {
            cell.isUserInteractionEnabled = true
        }
    }
    
}

extension UploadViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            if let cell = tableView.dequeueReusableCell(withIdentifier: kUploadImageTableViewCellId,
                                                        for: indexPath) as? UploadImageTableViewCell {
                if let prepopulatedSubmission = prepopulatedSubmission {
                    cell.configureCell(imageUrl: prepopulatedSubmission.dishImage?.image)
                } else {
                    cell.configureCell(image: uploadImage)
                }
                return cell
            }
        case 1:
            if let cell = tableView.dequeueReusableCell(withIdentifier: kUploadBasicInfoTableViewCellId,
                                                        for: indexPath) as? UploadBasicInfoTableViewCell {
                if let prepopulatedSubmission = prepopulatedSubmission {
                    cell.configureCell(menu: restaurantMenu, prefilledSubmission: prepopulatedSubmission)
                } else {
                    cell.configureCell(menu: restaurantMenu)
                }
                return cell
            }
        case 2:
            if let cell = tableView.dequeueReusableCell(withIdentifier: kAdditionalInfoTableViewCellId,
                                                        for: indexPath) as? AdditionalInfoTableViewCell {
                let prefilledDescription = prepopulatedSubmission?.dish?.description
                cell.configureCell(title: "Additional Notes",
                                   subtitle: "Let us know if you’ve changed anything about your dish from its original form.",
                                   placeholder: "e.g. extra rice, salad instead of fries",
                                   prefilledDescription: prefilledDescription)
                return cell
            }
        case 3:
            if let cell = tableView.dequeueReusableCell(withIdentifier: kUploadEarningsTableViewCellId,
                                                        for: indexPath) as? UploadEarningsTableViewCell {
                cell.configureCell(points: 50)
                return cell
            }
        default:
            break
        }
        assert(false)
        return UITableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let pickerController = DKImagePickerController()
            pickerController.setDefaultControllerProperties()
            pickerController.didSelectAssets = { (assets: [DKAsset]) in
                for asset in assets {
                    let options = PHImageRequestOptions()
                    options.isSynchronous = true
                    asset.fetchOriginalImage(options: options, completeBlock: { (image, _) in
                        if let img = image {
                            self.uploadImage = img
                        }
                    })
                }
            }
            self.present(pickerController, animated: true) {}
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = estimatedHeightDict[indexPath] {
            return height
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        estimatedHeightDict[indexPath] = cell.frame.size.height
    }
    
}
