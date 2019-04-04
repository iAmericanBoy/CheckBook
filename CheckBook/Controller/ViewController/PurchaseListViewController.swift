//
//  PurchaseListViewController.swift
//  CheckBook
//
//  Created by Dominic Lanzillotta on 4/3/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import UIKit

class PurchaseListViewController: UIViewController {
    
    //MARK: - Outlets
    private var addPurchaseViewController: AddPurchaseViewController?
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let addPurchaseCard = children.first as? AddPurchaseViewController else {
            fatalError("Check storyboard for missing AddPurchaseViewController")
        }
        
        addPurchaseCard.delegate = self
    }
    
    func autoHide() {
        guard let addPurchaseCard = addPurchaseViewController else {return}
        
        // Sets target locations of views & then animates.
        let cardTarget = self.view.frame.maxY - self.view.safeAreaInsets.bottom - (addPurchaseCard.view.bounds.height / 5)
        self.autoAnimate(view: addPurchaseCard.view, edge: addPurchaseCard.view.frame.minY, to: cardTarget, insightAlphaTarget: 1, completion: nil)
    }
    
    func autoShow() {
        guard let addPurchaseCard = addPurchaseViewController else {return}

        // Sets target locations of views & then animates.
        let cardTarget = self.view.frame.maxY - self.view.safeAreaInsets.bottom
        self.autoAnimate(view: addPurchaseCard.view, edge: addPurchaseCard.view.frame.maxY, to: cardTarget, insightAlphaTarget: 0, completion: nil)
    }
    
    func hideCard() {
        guard let addPurchaseCard = addPurchaseViewController else {return}

        // Sets target locations of views & then animates.
        let cardTarget = self.view.frame.maxY - self.view.safeAreaInsets.bottom - (addPurchaseCard.view.frame.height / 5)
        self.userInteractionAnimate(view: addPurchaseCard.view, edge: addPurchaseCard.view.frame.minY, to: cardTarget, velocity: addPurchaseCard.panGesture.velocity(in: addPurchaseCard.view).y, insightAlphaTarget: 1)
    }
    
    func showCard() {
        guard let addPurchaseCard = addPurchaseViewController else {return}

        // Sets target locations of views & then animates.
        let target = self.view.frame.maxY - self.view.safeAreaInsets.bottom
        self.userInteractionAnimate(view: addPurchaseCard.view, edge: addPurchaseCard.view.frame.maxY, to: target, velocity: addPurchaseCard.panGesture.velocity(in: addPurchaseCard.view).y, insightAlphaTarget: 0)
    }
    
    func userInteractionAnimate(view: UIView, edge: CGFloat, to target: CGFloat, velocity: CGFloat, insightAlphaTarget: CGFloat?) {
        let distanceToTranslate = target - edge
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.97, initialSpringVelocity: abs(velocity) * 0.01, options: .curveEaseOut , animations: {
            view.frame =  view.frame.offsetBy(dx: 0, dy: distanceToTranslate)
            if let alpha = insightAlphaTarget {
                view.alpha = alpha
            }
        })
    }
    
    func autoAnimate(view: UIView, edge: CGFloat, to target: CGFloat, insightAlphaTarget: CGFloat?, completion: ((Bool) -> Void)?) {
        let distanceToTranslate = target - edge
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
            view.frame =  view.frame.offsetBy(dx: 0, dy: distanceToTranslate)
            if let alpha = insightAlphaTarget {
                view.alpha = alpha
            }
        }, completion: completion)
    }
}

//MARK: - AddPurchaseCardDelegate
extension PurchaseListViewController: AddPurchaseCardDelegate {
    func panDidEnd() {
        guard let addPurchaseCard = addPurchaseViewController else {return}

        // Check the state when the pan gesture ends and react accordingly with linear or velocity reactive animations.
        let aboveHalfWay = addPurchaseCard.view.frame.minY < (self.view.frame.height * 0.5)
        let velocity = addPurchaseCard.panGesture.velocity(in: addPurchaseCard.view).y
        
        if velocity > 500 {
            self.hideCard()
        } else if velocity < -500 {
            self.showCard()
        } else if aboveHalfWay {
            self.autoShow()
        } else if !aboveHalfWay {
            self.autoHide()
        }
    }
    
    func userDidInteractWithCard() {
        guard let addPurchaseCard = addPurchaseViewController else {return}

        if addPurchaseCard.view.frame.minY > (self.view.frame.height * 0.5) {
            self.autoShow()
        }
    }
    
    func panViews(withPanPoint panPoint: CGPoint) {
        guard let addPurchaseCard = addPurchaseViewController else {return}

        // If user goes against necessary pan adjust reaction
        if addPurchaseCard.view.frame.maxY < self.view.bounds.maxY {
            // Don’t animate top bar with pan gesture
            addPurchaseCard.view.center.y += addPurchaseCard.panGesture.translation(in: addPurchaseViewController?.view).y / 4
        } else {
            // Normal reaction
            addPurchaseCard.view.center.y += addPurchaseCard.panGesture.translation(in: addPurchaseCard.view).y
        }
    }
}
