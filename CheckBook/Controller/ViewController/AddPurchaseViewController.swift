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
    
    //MARK: - Properties
    var delegate: AddPurchaseCardDelegate?

    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()

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
    }
    
    //MARK: - Private Functions
    fileprivate func setupViews() {
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 10
        
        pullView.layer.cornerRadius = 4
        
    }
}
