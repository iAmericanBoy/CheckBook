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
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
//    func panDidEnd() {
//        // Check the state when the pan gesture ends and react accordingly with linear or velocity reactive animations.
//        let aboveHalfWay = self.cardView.frame.minY < (self.view.frame.height * 0.5)
//        let velocity = self.cardView.panGesture?.velocity(in: self.cardView).y
//
//        if velocity > 500 {
//            self.hideCard()
//        } else if velocity < -500 {
//            self.showCard()
//        } else if aboveHalfWay {
//            self.autoShow()
//        } else if !aboveHalfWay {
//            self.autoHide()
//        }
//    }
//
//    func userDidInteractWithCard() {
//        if self.cardView.frame.minY > (self.view.frame.height * 0.5) {
//            self.autoShow()
//        }
//    }
//    func autoHide() {
//        // Sets target locations of views & then animates.
//        let cardTarget = self.view.frame.maxY - self.view.safeAreaInsets.bottom - (self.cardView.bounds.height / 5)
//        self.autoAnimate(view: self.cardView, edge: self.cardView.frame.minY, to: cardTarget, insightAlphaTarget: 1, completion: nil)
//
//        let topBarTarget: CGFloat = 0
//        self.autoAnimate(view: self.topBarView, edge: self.topBarView.frame.maxY, to: topBarTarget, insightAlphaTarget: nil, completion: nil)
//    }
//
//    func autoShow() {
//        // Sets target locations of views & then animates.
//        let cardTarget = self.view.frame.maxY - self.view.safeAreaInsets.bottom
//        self.autoAnimate(view: self.cardView, edge: self.cardView.frame.maxY, to: cardTarget, insightAlphaTarget: 0, completion: nil)
//
//        let topBarTarget: CGFloat = self.view.safeAreaInsets.top - (self.topBarView.frame.height / 2)
//        self.autoAnimate(view: self.topBarView, edge: self.topBarView.frame.minY, to: topBarTarget, insightAlphaTarget: nil, completion: nil)
//    }
//
//    func hideCard() {
//        // Sets target locations of views & then animates.
//        let cardTarget = self.view.frame.maxY - self.view.safeAreaInsets.bottom - (self.cardView.frame.height / 5)
//        self.userInteractionAnimate(view: self.cardView, edge: self.cardView.frame.minY, to: cardTarget, velocity: self.cardView.panGesture.velocity(in: self.cardView).y, insightAlphaTarget: 1)
//
//        let topBarTarget: CGFloat = 0
//        self.userInteractionAnimate(view: self.topBarView, edge: self.topBarView.frame.maxY, to: topBarTarget, velocity: self.cardView.panGesture.velocity(in: self.cardView).y, insightAlphaTarget: nil)
//    }
//
//    func showCard() {
//        // Sets target locations of views & then animates.
//        let target = self.view.frame.maxY - self.view.safeAreaInsets.bottom
//        self.userInteractionAnimate(view: self.cardView, edge: self.cardView.frame.maxY, to: target, velocity: self.cardView.panGesture.velocity(in: self.cardView).y, insightAlphaTarget: 0)
//
//        let topBarTarget: CGFloat = self.view.safeAreaInsets.top - (self.topBarView.frame.height / 2)
//        self.userInteractionAnimate(view: self.topBarView, edge: self.topBarView.frame.minY, to: topBarTarget, velocity: self.cardView.panGesture.velocity(in: self.cardView).y, insightAlphaTarget: nil)
//    }
//
//    func userInteractionAnimate(view: UIView, edge: CGFloat, to target: CGFloat, velocity: CGFloat, insightAlphaTarget: CGFloat?) {
//        let distanceToTranslate = target - edge
//        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.97, initialSpringVelocity: abs(velocity) * 0.01, options: .curveEaseOut , animations: {
//            view.frame =  view.frame.offsetBy(dx: 0, dy: distanceToTranslate)
//            if let alpha = insightAlphaTarget {
//                self.insightContainer?.view.alpha = alpha
//            }
//        }, completion: nil)
//    }
//
//    func autoAnimate(view: UIView, edge: CGFloat, to target: CGFloat, insightAlphaTarget: CGFloat?, completion: ((Bool) -> Void)?) {
//        let distanceToTranslate = target - edge
//        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
//            view.frame =  view.frame.offsetBy(dx: 0, dy: distanceToTranslate)
//            if let alpha = insightAlphaTarget {
//                self.insightContainer?.view.alpha = alpha
//            }
//        }, completion: completion)
//    }
//    func panViews(withPanPoint panPoint: CGPoint) {
//        // If user goes against necessary pan adjust reaction
//        if self.cardView.frame.maxY < self.view.bounds.maxY {
//            // Don’t animate top bar with pan gesture
//            self.cardView.center.y += cardView.panGesture.translation(in: cardView).y / 4
//        } else {
//            // Normal reaction
//            self.cardView.center.y += cardView.panGesture.translation(in: cardView).y
//            self.topBarView.center.y -= cardView.panGesture.translation(in: cardView).y / 3
//        }
//    }
    



}


