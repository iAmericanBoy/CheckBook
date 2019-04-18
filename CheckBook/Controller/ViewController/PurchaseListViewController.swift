//
//  PurchaseListViewController.swift
//  CheckBook
//
//  Created by Dominic Lanzillotta on 4/3/19.
//  Copyright © 2019 Dominic Lanzillotta. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation
import CloudKit

// MARK: - State
enum State {
    case closed
    case open
}

extension State {
    var opposite: State {
        switch self {
        case .open: return .closed
        case .closed: return .open
        }
    }
}

class PurchaseListViewController: UIViewController {
    
    //MARK: - Outlets
    private var addPurchaseViewController: AddPurchaseViewController?
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var purchaseList: UITableView!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var weekLabel: UILabel!
    //MARK: - Properties
    /// The current state of the animation. This variable is changed only when an animation completes.
    private var currentState: State = .closed
    var impact = UIImpactFeedbackGenerator(style: .light)

    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        fetchChangesFromCK()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(forName: Notification.syncFinished.name, object: nil, queue: .main) { (_) in
            self.purchaseList.reloadData()
        }
        NotificationCenter.default.addObserver(forName: Notification.ledgerAlreadyExists.name, object: nil, queue: .main) { (_) in
            self.tooManyLedgers {
                self.performSegue(withIdentifier: "toSettingsVC", sender: nil)
            }
        }
    }
    
    func hideCard() {
        guard let addPurchaseCard = addPurchaseViewController else {return}

        // Sets target locations of views & then animates.
        let cardTarget = self.view.frame.maxY  - 75
        self.userInteractionAnimate(forState: .closed, animatedView: cardView, edge: cardView.frame.minY, to: cardTarget, velocity: addPurchaseCard.panGesture.velocity(in: cardView).y, insightAlphaTarget: 1)
    }
    
    func showCard() {
        guard let addPurchaseCard = addPurchaseViewController else {return}

        // Sets target locations of views & then animates.
        let target = self.view.frame.maxY
        self.userInteractionAnimate(forState: .open, animatedView: cardView, edge: cardView.frame.maxY, to: target, velocity: addPurchaseCard.panGesture.velocity(in: cardView).y, insightAlphaTarget: 0)
    }
    
    fileprivate func userInteractionAnimate(forState state: State, animatedView: UIView, edge: CGFloat, to target: CGFloat, velocity: CGFloat, insightAlphaTarget: CGFloat?) {
        guard let addPurchaseCard = addPurchaseViewController else {return}
        
        let distanceToTranslate = target - edge
        
        let timing = UISpringTimingParameters(damping: 0.8, response: 0.3, initialVelocity: CGVector(dx: 0, dy: abs(velocity) * 0.01))
        let transitionAnimator = UIViewPropertyAnimator(duration: 0.5, timingParameters: timing)
        transitionAnimator.addAnimations {
            switch state {
            case .open:
                animatedView.frame = animatedView.frame.offsetBy(dx: 0, dy: distanceToTranslate)
                self.overlayView.alpha = 0.5
                
                addPurchaseCard.view.layer.cornerRadius = 20
                addPurchaseCard.pullView.alpha = 0.5
                animatedView.layoutIfNeeded()
            case .closed:
                animatedView.frame = animatedView.frame.offsetBy(dx: 0, dy: distanceToTranslate)
                self.overlayView.alpha = 0
                
                addPurchaseCard.view.layer.cornerRadius = 0
                addPurchaseCard.pullView.alpha = 0

                animatedView.layoutIfNeeded()
            }


            self.view.layoutIfNeeded()
        }
        transitionAnimator.addAnimations({
            self.impact.prepare()
            self.impact.impactOccurred()
        }, delayFactor: 1.0)
        
        transitionAnimator.addCompletion { (position) in

            // update the state
            switch position {
            case .start:
                self.currentState = state.opposite
            case .end:
                self.currentState = state
            case .current:
                ()
            }
        }
        
        transitionAnimator.startAnimation()
    }
    

    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? AddPurchaseViewController {
            addPurchaseViewController = destinationVC
            destinationVC.delegate = self
        }
    }
    
    //MARK: - Private Functions
    fileprivate func setupViews() {
        purchaseList.tableFooterView = UIView()
        purchaseList.delegate = self
        purchaseList.dataSource = self
        purchaseList.register(PurchaseHeader.self, forHeaderFooterViewReuseIdentifier: PurchaseHeader.reuseIdentifier)
        CoreDataController.shared.purchaseFetchResultsController.delegate = self
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.1
        cardView.layer.shadowRadius = 10
        calculateTotals()
    }
    
    fileprivate func calculateTotals() {
        let beginningOfWeek = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))
        let beginningOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))


        let purchasesOfWeek = CoreDataController.shared.purchaseFetchResultsController.fetchedObjects?.filter({ (purchase) -> Bool in
            return Calendar.current.compare(purchase.day! as Date, to: beginningOfWeek!, toGranularity: Calendar.Component.second).rawValue > 0
        })
        let purchasesOfMonth = CoreDataController.shared.purchaseFetchResultsController.fetchedObjects?.filter({ (purchase) -> Bool in
            return Calendar.current.compare(purchase.day! as Date, to: beginningOfMonth!, toGranularity: Calendar.Component.second).rawValue > 0
        })
        
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale.autoupdatingCurrent
        numberFormatter.numberStyle = .currency
        
        var weekTotal:NSDecimalNumber = 0.0
        
        if let purchasesOfWeek = purchasesOfWeek {
            for purchase in purchasesOfWeek {
                weekTotal = weekTotal.adding(purchase.amount ?? 0)
            }
            weekLabel.text = numberFormatter.string(from: weekTotal)
        }
        var monthTotal:NSDecimalNumber = 0.0
        
        if let purchasesOfMonth = purchasesOfMonth {
            for purchase in purchasesOfMonth {
                monthTotal = monthTotal.adding(purchase.amount ?? 0)
            }
            monthLabel.text = numberFormatter.string(from: monthTotal)
        }
    }
    
    fileprivate func fetchChangesFromCK() {
        //Check for updates from Ck
        //-> If there are updates update Context
        //-> after that try to upload cached Purchases to CK
        CloudKitController.shared.fetchUpdatedRecordsFromCK { (isSuccess, recordsToUpdate, recordIDsToDelete) in
            if isSuccess {
                SyncController.shared.updateContextWith(fetchedRecordsToUpdate: recordsToUpdate, deletedRecordIDs: recordIDsToDelete)
            }
            SyncController.shared.saveCachedPurchasesToCK()

            //Fetch Share
            if let stringURL = CoreDataController.shared.ledgersFetchResultsController.fetchedObjects?.first?.url, let url = URL(string: stringURL) {
                CloudKitController.shared.fetchShareMetadata(forURL: url) { (isSuccess, share) in
                    if isSuccess {
                        CloudKitController.shared.currentShare = share
                    }
                }
            }
        }
        CloudKitController.shared.fetchUpdatedRecordsFromCK(inDataBase: CloudKitController.shared.shareDB) { (isSuccess, recordsToUpdate, recordIDsToDelete) in
            if isSuccess {
                SyncController.shared.updateContextWith(fetchedRecordsToUpdate: recordsToUpdate, deletedRecordIDs: recordIDsToDelete)
            }
            if let stringURL = CoreDataController.shared.ledgersFetchResultsController.fetchedObjects?.first?.url, let url = URL(string: stringURL) {
                CloudKitController.shared.fetchShareMetadata(forURL: url) { (isSuccess, share) in
                    if isSuccess {
                        CloudKitController.shared.currentShare = share
                    }
                }
            }
        }
    }
}

//MARK: - AddPurchaseCardDelegate
extension PurchaseListViewController: AddPurchaseCardDelegate {
    func panDidEnd() -> State {
        guard let addPurchaseCard = addPurchaseViewController else {return State.closed}

        // Check the state when the pan gesture ends and react accordingly with linear or velocity reactive animations.
        let aboveHalfWay = cardView.frame.minY < (self.view.frame.height * 0.5)
        let velocity = addPurchaseCard.panGesture.velocity(in: cardView).y
        if velocity > 500 {
            self.hideCard()
            return State.closed
        } else if velocity < -500 {
            self.showCard()
            return State.open
        } else if aboveHalfWay {
            self.showCard()
            return State.open
        } else if !aboveHalfWay {
            self.hideCard()
            return State.closed
        } else {
            return State.closed
        }
    }
    
    func userDidInteractWithCard() -> State {
        if cardView.frame.minY > (self.view.frame.height * 0.5) {
            self.showCard()
            return State.open
        } else {
            self.hideCard()
            return State.closed
        }
    }
    
    func panViews(withPanPoint panPoint: CGPoint) {
        guard let addPurchaseCard = addPurchaseViewController else {return}

        // If user goes against necessary pan adjust reaction
        if cardView.frame.maxY < self.view.bounds.maxY {
            // Don’t animate top bar with pan gesture
            cardView.center.y += addPurchaseCard.panGesture.translation(in: cardView).y / 4
        } else {
            // Normal reaction
            cardView.center.y += addPurchaseCard.panGesture.translation(in: cardView).y
        }
    }
}

extension UISpringTimingParameters {
    convenience init(damping: CGFloat, response: CGFloat, initialVelocity: CGVector = .zero) {
        let stiffness = pow(2 * .pi / response, 2)
        let damp = 4 * .pi * damping / response
        self.init(mass: 1, stiffness: stiffness, damping: damp, initialVelocity: initialVelocity)
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension PurchaseListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return CoreDataController.shared.purchaseFetchResultsController.sections?.count ?? 0
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: PurchaseHeader.reuseIdentifier) as? PurchaseHeader
        
        view?.purchases = CoreDataController.shared.purchaseFetchResultsController.sections?[section].objects as? [Purchase]
        
        return view
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CoreDataController.shared.purchaseFetchResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "purchaseCell", for: indexPath) as? PurchaseTableViewCell
        
        cell?.purchase = CoreDataController.shared.purchaseFetchResultsController.object(at: indexPath)
        
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let purchase = CoreDataController.shared.purchaseFetchResultsController.object(at: indexPath)
            PurchaseController.shared.delete(purchase: purchase)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let purchase = CoreDataController.shared.purchaseFetchResultsController.object(at: indexPath)
        self.addPurchaseViewController?.currentState = .open
        self.addPurchaseViewController?.purchase = purchase
        self.showCard()
    }
}

//MARK: - NSFetchedResultsControllerDelegate
extension PurchaseListViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        purchaseList.beginUpdates()
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        purchaseList.endUpdates()
        calculateTotals()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else {return}
            purchaseList.insertRows(at: [newIndexPath], with: .automatic)
            
            if controller.sections?[newIndexPath.section].numberOfObjects ?? 1 > 1 {
                purchaseList.reloadSections(IndexSet(arrayLiteral: newIndexPath.section), with: .automatic)
            }
        case .delete:
            guard let indexPath = indexPath else {return}
            purchaseList.deleteRows(at: [indexPath], with: .automatic)
            if purchaseList.numberOfRows(inSection: indexPath.section) > 1 {
                purchaseList.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic)
            }

        case .move:
            guard let newIndexPath = newIndexPath, let indexPath = indexPath else {return}
            purchaseList.moveRow(at: indexPath, to: newIndexPath)
            if purchaseList.numberOfRows(inSection: indexPath.section) > 1 {
                purchaseList.reloadSections(IndexSet(arrayLiteral: newIndexPath.section, indexPath.section), with: .automatic)
            }

        case .update:
            guard let indexPath = indexPath else {return}
            purchaseList.reloadRows(at: [indexPath], with: .automatic)
            if purchaseList.numberOfRows(inSection: indexPath.section) > 0 {
                purchaseList.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic)
            }
        }
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        
        switch type {
        case .insert:
            purchaseList.insertSections(indexSet, with: .automatic)
        case .delete:
            purchaseList.deleteSections(indexSet, with: .automatic)
        case .update:
            print(indexSet)
            purchaseList.reloadSections(indexSet, with: .automatic)
        case .move:
            purchaseList.reloadSections(indexSet, with: .automatic)
        }
    }
}
