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
import Crashlytics

let kFormComponentTableViewCellId = "FormComponentTableViewCellId"
let kUploadImageTableViewCellId = "UploadImageTableViewCellId"
let kUploadBasicInfoTableViewCellId = "UploadBasicInfoTableViewCellId"
let kAdditionalInfoTableViewCellId = "AdditionalInfoTableViewCellId"
let kUploadEarningsTableViewCellId = "UploadEarningsTableViewCellId"
let kUploadRestaurantTableViewCellId = "UploadRestaurantTableViewCellId"
let kUploadRestaurantIfNewTableViewCellId = "UploadRestaurantIfNewTableViewCellId"

enum UploadFormError: Error {
    case required
    case price
}

protocol UploadViewControllerDelegate: class {
    func onSuccessfulUpload()
}

class UploadViewController: UIViewController {

    var tableView = UITableView()
    
    var restaurant: Restaurant?
    var newRestaurantName: String?
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
        tableView.register(UploadRestaurantTableViewCell.self,
                           forCellReuseIdentifier: kUploadRestaurantTableViewCellId)
        tableView.register(UploadRestaurantIfNewTableViewCell.self,
                           forCellReuseIdentifier: kUploadRestaurantIfNewTableViewCellId)
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
                } else if let prepopulatedSubmission = prepopulatedSubmission {
                    description = prepopulatedSubmission.dish?.description
                }
                
                GradientLoadingBar.shared.show()
                sender?.isEnabled = false
                let sectionText = cell.dishSectionTextField.text
                
                Answers.logContentView(withName: "Upload-SubmissionRequest", contentType: "submission", contentId: nil,
                                       customAttributes: ["restaurant": restaurant?.id ?? -1,
                                                          "itemName": cell.dishTextField.text,
                                                          "itemSection": sectionText,
                                                          "description": description])
                
                if uploadImage != nil {
                    NetworkManager.shared.insertMenuItem(restaurantId: restaurant?.id ?? -1,
                                                         itemName: cell.dishTextField.text,
                                                         itemImage: uploadImage,
                                                         description: description,
                                                         sectionName: sectionText == kNoSection ? "" : sectionText,
                                                         price: cell.priceFloat) { (_, error, _) in
                                                            GradientLoadingBar.shared.hide()
                                                            if error == nil {
                                                                Answers.logContentView(withName: "Upload-SubmissionSuccess", contentType: "submission", contentId: nil,
                                                                                       customAttributes: ["restaurant": self.restaurant?.id ?? -1,
                                                                                                          "itemName": cell.dishTextField.text,
                                                                                                          "itemSection": sectionText,
                                                                                                          "description": description])
                                                                self.delegate?.onSuccessfulUpload()
                                                                self.navigationController?.popViewController(animated: true)
                                                            } else {
                                                                sender?.isEnabled = true
                                                            }
                    }
                } else {
                    // only on resubmission with same image
                    NetworkManager.shared.insertMenuItem(restaurantId: restaurant?.id ?? -1,
                                                         itemName: cell.dishTextField.text,
                                                         itemImageUrl: prepopulatedSubmission?.dishImage?.image,
                                                         description: description,
                                                         sectionName: sectionText == kNoSection ? "" : sectionText,
                                                         price: cell.priceFloat) { (_, error, _) in
                                                            GradientLoadingBar.shared.hide()
                                                            if error == nil {
                                                                Answers.logContentView(withName: "Upload-SubmissionSuccess", contentType: "submission", contentId: nil,
                                                                                       customAttributes: ["restaurant": self.restaurant?.id ?? -1,
                                                                                                          "itemName": cell.dishTextField.text,
                                                                                                          "itemSection": sectionText,
                                                                                                          "description": description,])
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
        let offset = restaurant == nil ? 1 : 0
        
        if restaurant == nil, indexPath.row == 2 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: kUploadRestaurantIfNewTableViewCellId, for: indexPath) as? UploadRestaurantIfNewTableViewCell {
                cell.configureCell(restaurantName: newRestaurantName)
                return cell
            }
        }
        
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
            if let cell = tableView.dequeueReusableCell(withIdentifier: kUploadRestaurantTableViewCellId,
                                                        for: indexPath) as? UploadRestaurantTableViewCell {
                cell.configureCell(restaurant: restaurant)
                cell.delegate = self
                return cell
            }
        case 2 + offset:
            if let cell = tableView.dequeueReusableCell(withIdentifier: kUploadBasicInfoTableViewCellId,
                                                        for: indexPath) as? UploadBasicInfoTableViewCell {
                if let prepopulatedSubmission = prepopulatedSubmission {
                    cell.configureCell(menu: restaurant?.menu, prefilledSubmission: prepopulatedSubmission)
                } else {
                    cell.configureCell(menu: restaurant?.menu)
                }
                return cell
            }
        case 3 + offset:
            if let cell = tableView.dequeueReusableCell(withIdentifier: kAdditionalInfoTableViewCellId,
                                                        for: indexPath) as? AdditionalInfoTableViewCell {
                let prefilledDescription = prepopulatedSubmission?.dish?.description
                cell.configureCell(title: "Description",
                                   subtitle: "Describe the dish and mention if you’ve changed anything about your dish from its original form.",
                                   placeholder: "e.g. thin noodles, salad instead of fries",
                                   prefilledDescription: prefilledDescription)
                return cell
            }
        case 4 + offset:
            if let cell = tableView.dequeueReusableCell(withIdentifier: kUploadEarningsTableViewCellId,
                                                        for: indexPath) as? UploadEarningsTableViewCell {
                cell.configureCell(points: 50)
                return cell
            }
        default:
            break
        }

        return UITableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5 + (restaurant == nil ? 1 : 0)
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

extension UploadViewController: UploadRestaurantTableViewCellDelegate {
    func restaurantExistenceDidChange(restaurant: Restaurant?, orName: String?) {
        self.restaurant = restaurant
        self.newRestaurantName = orName
        if restaurant != nil {
            tableView.deleteRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
        } else {
            tableView.insertRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
        }
    }
    
    func newNonExistentNameTyped(name: String?) {
        self.newRestaurantName = name
        if let cell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? UploadRestaurantIfNewTableViewCell {
            cell.restaurantName = name
            cell.setMapRegion()
        }
    }
}
