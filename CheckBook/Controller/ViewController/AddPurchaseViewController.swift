//
//  AddPurchaseCard.swift
//  CheckBook
//
//  Created by Dominic Lanzillotta on 4/3/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import UIKit

protocol AddPurchaseCardDelegate: class {
    func panDidEnd()
    func userDidInteractWithCard()
    func panViews(withPanPoint panPoint:CGPoint)
}

class AddPurchaseViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet var panGesture: UIPanGestureRecognizer!
    @IBOutlet weak var pullView: UIView!
    @IBOutlet weak var addPurchaseButton: UIButton!
    @IBOutlet weak var storeNameTextField: UITextField!
    @IBOutlet weak var methodTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet var toolBar: UIToolbar!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var methodPickerView: UIPickerView!
    @IBOutlet var paymentMethodToolBar: UIToolbar!
    @IBOutlet var categoryToolBar: UIToolbar!
    @IBOutlet var categoryPickerView: UIPickerView!
    
    //MARK: - Properties
    var delegate: AddPurchaseCardDelegate?

    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification,object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    //MARK: - Actions
    @IBAction func handlePan(_ sender: UIPanGestureRecognizer) {
        dismissKeyBoards()
        switch sender.state {
        case .began:
            delegate?.panViews(withPanPoint: CGPoint(x: view.center.x, y: view.center.y + sender.translation(in: view).y))
            sender.setTranslation(CGPoint.zero, in: view)
        case .changed:
            delegate?.panViews(withPanPoint: CGPoint(x: view.center.x, y: view.center.y + sender.translation(in: view).y))
            sender.setTranslation(CGPoint.zero, in: view)
        case .ended:
            sender.setTranslation(CGPoint.zero, in: view)
            delegate?.panDidEnd()
        default:
            return
        }
    }

    @IBAction func addPurchaseButtonTapped(_ sender: UIButton) {
        delegate?.userDidInteractWithCard()
        dismissKeyBoards()
    }
    
    @IBAction func addNewCardButtonTapped(_ sender: UIBarButtonItem) {
        //TODO: Present Alert
    }
    @IBAction func newCategoryButtonTapped(_ sender: UIBarButtonItem) {
        //TODO: PresentAlert
    }
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        dismissKeyBoards()
    }
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.dateStyle = .medium
        dateTextField.text = dateFormatter.string(from: sender.date)
    }
    
    //MARK: - Private Functions
    fileprivate func setupViews() {
        storeNameTextField.delegate = self
        amountTextField.delegate = self
        
        categoryTextField.delegate = self
        categoryTextField.inputAccessoryView = categoryToolBar
        categoryTextField.inputView = categoryPickerView
        categoryPickerView.dataSource = self
        categoryPickerView.delegate = self
        
        methodTextField.delegate = self
        methodTextField.inputAccessoryView = paymentMethodToolBar
        methodTextField.inputView = methodPickerView
        methodPickerView.delegate = self
        methodPickerView.dataSource = self
        
        dateTextField.delegate = self
        dateTextField.inputAccessoryView = toolBar
        dateTextField.inputView = datePicker
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.dateStyle = .medium
        dateTextField.text = dateFormatter.string(from: Date())
        
        amountTextField.inputAccessoryView = toolBar
        
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.layer.cornerRadius = 20

        pullView.layer.cornerRadius = 4
    }
    
    fileprivate func dismissKeyBoards() {
        storeNameTextField.resignFirstResponder()
        methodTextField.resignFirstResponder()
        amountTextField.resignFirstResponder()
        dateTextField.resignFirstResponder()
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        }
    }
}

//MARK: - UITextFieldDelegate
extension AddPurchaseViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {

    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        textField.resignFirstResponder()
        return true
    }
}

//MARK: - UIPickerViewDelegate, UIPickerViewDataSource
extension AddPurchaseViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return CoreDataController.shared.purchaseMethodFetchResultsController.sections?.count ?? 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return CoreDataController.shared.purchaseMethodFetchResultsController.sections?[component].numberOfObjects ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return CoreDataController.shared.purchaseMethodFetchResultsController.object(at: IndexPath(item: row, section: component)).name
    }
}
