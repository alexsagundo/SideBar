//
//  SideBar.swift
//  SideBar
//
//  Created by proyectosCetina on 7/3/15.
//  Copyright (c) 2015 proyectosSagundo. All rights reserved.
//

import UIKit

@objc protocol SideBarDelegate{
    func sideBarDidSelectButtonAtIndex(index:Int)
    optional func sideBarWillClose()
    optional func sideBarWillOpen()
}
class SideBar: NSObject, SideBarTableViewControllerDelegate {
    let barWidth:CGFloat=150.0
    let sideBarTableViewTopInset:CGFloat=64.0
    let sideBarContainerView:UIView=UIView()
    let sideBarTableViewController:SideBarTableViewController=SideBarTableViewController()
    let originView:UIView!
    
    var animator:UIDynamicAnimator!
    var delegate:SideBarDelegate?
    var isSideBarOpen:Bool=false
    
    override init(){
        super.init()
    }
   
    init(sourceView:UIView, menuItems:Array<String>) {
        super.init()
        originView=sourceView
        sideBarTableViewController.tableData = menuItems
        
        setupSideBar()
        
        animator=UIDynamicAnimator(referenceView: originView)
        
        let showGestureRecognizer:UISwipeGestureRecognizer=UISwipeGestureRecognizer(target: self, action: "handleSwipe")
        showGestureRecognizer.direction=UISwipeGestureRecognizerDirection.Right
        originView.addGestureRecognizer(showGestureRecognizer)
        let hideGestureRecognizer:UISwipeGestureRecognizer=UISwipeGestureRecognizer(target: self, action: "handleSwipe")
        hideGestureRecognizer.direction=UISwipeGestureRecognizerDirection.Left
        originView.addGestureRecognizer(hideGestureRecognizer)
        
    }
    
    
    func setupSideBar(){
    sideBarContainerView.frame= CGRectMake(-barWidth -1, originView.frame.origin.y, barWidth, originView.frame.size.height)
        sideBarContainerView.backgroundColor=UIColor.clearColor()
        sideBarContainerView.clipsToBounds=false
        
        originView.addSubview(sideBarContainerView)
        let blurView:UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
        blurView.frame=sideBarContainerView.bounds
        sideBarContainerView.addSubview(blurView)
        
        sideBarTableViewController.delegate = self
        sideBarTableViewController.tableView.frame = sideBarContainerView.bounds
        sideBarTableViewController.tableView.clipsToBounds = false
        sideBarTableViewController.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        sideBarTableViewController.tableView.scrollsToTop=false
        sideBarTableViewController.tableView.contentInset = UIEdgeInsetsMake(sideBarTableViewTopInset, 0, 0, 0)
        
        sideBarTableViewController.tableView.reloadData()
        sideBarContainerView.addSubview(sideBarTableViewController.tableView)
    }
    
    func handleSwipe(recognizer: UISwipeGestureRecognizer){
        if recognizer.direction == UISwipeGestureRecognizerDirection.Left{
            showSiderBar(false)
            delegate?.sideBarWillClose?()
        }else{
            showSiderBar(true)
            delegate?.sideBarWillOpen?()
        }
        
    }
    
    func showSiderBar(shouldOpen:Bool){
        animator.removeAllBehaviors()
        isSideBarOpen=shouldOpen
        
        let gravityX:CGFloat=(shouldOpen) ? 0.5 : -0.5
        let magnitude:CGFloat=(shouldOpen) ? 20: -20
        let boundaryX:CGFloat=(shouldOpen) ? barWidth : -barWidth - 1
        
        let gravityBehavior:UIGravityBehavior(items: [sideBarContainerView])
        gravityBehavior.gravityDirection=CGVectorMake(gravityX, 0)
        animator.addBehavior(gravityBehavior)
        
        let collisionBehavior:UICollisionBehavior = UICollisionBehavior(items:[sideBarContainerView])
        collisionBehavior.addBoundaryWithIdentifier("sideBarBoundary", fromPoint: CGPointMake(boundaryX, 20), toPoint: CGPointMake(boundaryX, originView.frame.size.height))
        animator.addBehavior(collisionBehavior)
        
    }
    
    
    func sideBarControlDidSelectRow(indexPath: NSIndexPath) {
        delegate?.sideBarDidSelectButtonAtIndex(indexPath.row)
    }
    
}
