//
//  AddPurchaseCard.swift
//  CheckBook
//
//  Created by Dominic Lanzillotta on 4/3/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import UIKit

protocol AddPurchaseCardDelegate: class {
    func panDidEnd() -> State
    func userDidInteractWithCard() -> State
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
    @IBOutlet weak var ledgerTextField: UITextField!
    @IBOutlet var dateToolBar: UIToolbar!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var methodPickerView: UIPickerView!
    @IBOutlet var paymentMethodToolBar: UIToolbar!
    @IBOutlet var categoryToolBar: UIToolbar!
    @IBOutlet var categoryPickerView: UIPickerView!
    @IBOutlet var ledgerToolBar: UIToolbar!
    @IBOutlet var ledgerPickerView: UIPickerView!
    
    //MARK: - Properties
    var delegate: AddPurchaseCardDelegate?
    /// The current state of the card.
    var currentState: State = .open
    let numberFormatter = NumberFormatter()
    var purchase: Purchase? {
        didSet {
            currentState = .open
            updateViews()
        }
    }

    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        updateViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification,object: nil)
        NotificationCenter.default.addObserver(forName: Notification.syncFinished.name, object: nil, queue: .main) { (_) in
            self.methodPickerView.reloadAllComponents()
            self.categoryPickerView.reloadAllComponents()
//            self.categoryTextField.text = CoreDataController.shared.categoryFetchResultsController.object(at: IndexPath(item: 0, section: 0)).name
//            self.methodTextField.text = CoreDataController.shared.purchaseMethodFetchResultsController.object(at: IndexPath(item: 0, section: 0)).name

        }
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
            currentState = delegate?.panDidEnd() ?? State.closed
            updateViews()
        default:
            return
        }
    }

    @IBAction func addPurchaseButtonTapped(_ sender: UIButton) {
        currentState = delegate?.userDidInteractWithCard() ?? State.closed
        dismissKeyBoards()

        let methodRow = methodPickerView.selectedRow(inComponent: 0)
        let categoryRow = categoryPickerView.selectedRow(inComponent: 0)
        let date = datePicker.date
        guard let storeName = storeNameTextField.text, !storeName.isEmpty,
            let amount = amountTextField.text, let amountNumber = numberFormatter.number(from: amount),
            let methodText = methodTextField.text, !methodText.isEmpty,
            let categoryText = methodTextField.text, !categoryText.isEmpty else {updateViews(); return}
        
        //Set TextFields to Empty
        amountTextField.text = NumberFormatter.localizedString(from: 0, number: .currency)
        storeNameTextField.text = ""

        let method = CoreDataController.shared.purchaseMethodFetchResultsController.object(at: IndexPath(row: methodRow, section: 0))
        let category = CoreDataController.shared.categoryFetchResultsController.object(at: IndexPath(row: categoryRow, section: 0))
        
        
        if let purchase = purchase {
            PurchaseController.shared.update(purchase: purchase, amount: NSDecimalNumber(decimal: amountNumber.decimalValue) as Decimal, date: date, item: "", storeName: storeName, purchaseMethod: method, category: category)
        } else {
            if let ledger = CoreDataController.shared.ledgerFetchResultsController.fetchedObjects?.first {
                PurchaseController.shared.createNewPurchaseWith(amount: NSDecimalNumber(decimal: amountNumber.decimalValue), date: date, item: "", storeName: storeName, purchaseMethod: method, ledger: ledger, category: category)
            } else {
                let newLedger = LedgerController.shared.createNewLedgerWith(name: "Hello")
                PurchaseController.shared.createNewPurchaseWith(amount: NSDecimalNumber(decimal: amountNumber.decimalValue), date: date, item: "", storeName: storeName, purchaseMethod: method, ledger: newLedger, category: category)
            }
        }
        purchase = nil

        updateViews()
    }
    
    @IBAction func addNewCardButtonTapped(_ sender: UIBarButtonItem) {
        self.addNewPurchaseMethodAlert {
            DispatchQueue.main.async {
                try! CoreDataController.shared.purchaseMethodFetchResultsController.performFetch()
                self.methodPickerView.reloadAllComponents()
            }
        }
    }
    
    @IBAction func newCategoryButtonTapped(_ sender: UIBarButtonItem) {
        self.addNewCategoryAlert {
            DispatchQueue.main.async {
                try! CoreDataController.shared.categoryFetchResultsController.performFetch()
                self.categoryPickerView.reloadAllComponents()
            }
        }
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
    fileprivate func updateViews() {
        switch currentState {
        case .open:
            addPurchaseButton.setTitle("Save Purchase", for: .normal)
            categoryTextField.isHidden = false
            methodTextField.isHidden = false
            storeNameTextField.isHidden = false
            dateTextField.isHidden = false
            amountTextField.isHidden = false
        case .closed:
            addPurchaseButton.setTitle("Add Purchase", for: .normal)
            categoryTextField.isHidden = true
            methodTextField.isHidden = true
            storeNameTextField.isHidden = true
            dateTextField.isHidden = true
            amountTextField.isHidden = true

        }
        
        if let purchase = purchase {
            //updatePurchaseMode
            switch currentState {
            case .open:
                addPurchaseButton.setTitle("Update Purchase", for: .normal)
            case .closed:
                addPurchaseButton.setTitle("Add Purchase", for: .normal)
            }
            storeNameTextField.text = purchase.storeName
            amountTextField.text = NumberFormatter.localizedString(from: purchase.amount ?? 0, number: .currency)
            categoryTextField.text = purchase.category?.name
            if let categoryIndex = CoreDataController.shared.categoryFetchResultsController.indexPath(forObject: purchase.category!) {
                categoryPickerView.selectRow(categoryIndex.row, inComponent: categoryIndex.section, animated: true)
            }
            methodTextField.text = purchase.purchaseMethod?.name
            if let purchaseMethodIndex = CoreDataController.shared.purchaseMethodFetchResultsController.indexPath(forObject: purchase.purchaseMethod!) {
                methodPickerView.selectRow(purchaseMethodIndex.row, inComponent: purchaseMethodIndex.section, animated: true)
            }
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale.autoupdatingCurrent
            dateFormatter.dateStyle = .medium
            datePicker.date = purchase.date as Date? ?? Date()
            dateTextField.text = dateFormatter.string(from: purchase.date as Date? ?? Date())
        }
    }
    
    fileprivate func setupViews() {
        numberFormatter.numberStyle = .currency

        storeNameTextField.delegate = self
        amountTextField.delegate = self
        amountTextField.text = NumberFormatter.localizedString(from: 0, number: .currency)
        
        categoryTextField.delegate = self
        categoryTextField.inputAccessoryView = categoryToolBar
        categoryTextField.inputView = categoryPickerView
        categoryPickerView.dataSource = self
        categoryPickerView.delegate = self
        if CoreDataController.shared.categoryFetchResultsController.fetchedObjects?.count ?? 0 > 0 {
            categoryTextField.text = CoreDataController.shared.categoryFetchResultsController.object(at: IndexPath(item: 0, section: 0)).name
        }
        
        methodTextField.delegate = self
        methodTextField.inputAccessoryView = paymentMethodToolBar
        methodTextField.inputView = methodPickerView
        if CoreDataController.shared.purchaseMethodFetchResultsController.fetchedObjects?.count ?? 0 > 0 {
            methodTextField.text = CoreDataController.shared.purchaseMethodFetchResultsController.object(at: IndexPath(item: 0, section: 0)).name
        }
        
        ledgerTextField.delegate = self
        ledgerTextField.inputAccessoryView = ledgerToolBar
        ledgerTextField.inputView = ledgerPickerView
        

        methodPickerView.delegate = self
        methodPickerView.dataSource = self
        
        dateTextField.delegate = self
        dateTextField.inputAccessoryView = dateToolBar
        dateTextField.inputView = datePicker
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.dateStyle = .medium
        dateTextField.text = dateFormatter.string(from: Date())
        
        amountTextField.inputAccessoryView = dateToolBar
        
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.layer.cornerRadius = 20

        pullView.layer.cornerRadius = pullView.frame.height / 2
    }
    
    fileprivate func dismissKeyBoards() {
        storeNameTextField.resignFirstResponder()
        methodTextField.resignFirstResponder()
        amountTextField.resignFirstResponder()
        dateTextField.resignFirstResponder()
        categoryTextField.resignFirstResponder()
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight - 22, right: 0)
        }
    }
}

//MARK: - UITextFieldDelegate
extension AddPurchaseViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {

    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == amountTextField {
            guard let text = textField.text else {return true}
            
            let oldDigits = numberFormatter.number(from: text) ?? 0
            var digits = oldDigits.decimalValue
            
            if let digit = Decimal(string: string) {
                let newDigits: Decimal = digit / 100
            
                digits *= 10
                digits += newDigits
            }
            if range.length == 1 {
                digits /= 10
                var result = Decimal(integerLiteral: 0)
                NSDecimalRound(&result, &digits, 2, Decimal.RoundingMode.down)
                digits = result
            }
            
            textField.text = NumberFormatter.localizedString(from: digits as NSDecimalNumber, number: .currency)
            return false
        } else {
            return true
        }
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
        if pickerView.tag == 1111 {
            return CoreDataController.shared.purchaseMethodFetchResultsController.sections?.count ?? 1
        } else if pickerView.tag == 2222 {
            return CoreDataController.shared.categoryFetchResultsController.sections?.count ?? 1
        } else {
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1111 {
            return CoreDataController.shared.purchaseMethodFetchResultsController.sections?[component].numberOfObjects ?? 0
        } else if pickerView.tag == 2222 {
            return CoreDataController.shared.categoryFetchResultsController.sections?[component].numberOfObjects ?? 0
        } else {
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1111 {
            return CoreDataController.shared.purchaseMethodFetchResultsController.object(at: IndexPath(item: row, section: component)).name
        } else if pickerView.tag == 2222 {
            return CoreDataController.shared.categoryFetchResultsController.object(at: IndexPath(item: row, section: component)).name
        } else {
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1111 {
            methodTextField.text = CoreDataController.shared.purchaseMethodFetchResultsController.object(at: IndexPath(item: row, section: component)).name
        } else if pickerView.tag == 2222 {
            categoryTextField.text = CoreDataController.shared.categoryFetchResultsController.object(at: IndexPath(item: row, section: component)).name
        } else {
            
        }
    }
}
