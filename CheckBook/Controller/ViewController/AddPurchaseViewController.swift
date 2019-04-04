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
        storeNameTextField.resignFirstResponder()
        amountTextField.resignFirstResponder()
        dateTextField.resignFirstResponder()
        methodTextField.resignFirstResponder()
    }
    
    //MARK: - Private Functions
    fileprivate func setupViews() {
        
        storeNameTextField.delegate = self
        amountTextField.delegate = self
        dateTextField.delegate = self
        methodTextField.delegate = self

        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 10
        
        pullView.layer.cornerRadius = 4
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        }
    }
}

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
