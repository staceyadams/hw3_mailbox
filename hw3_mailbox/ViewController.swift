//
//  ViewController.swift
//  hw3_mailbox
//
//  Created by Stacey Adams on 2/19/15.
//  Copyright (c) 2015 Codepath. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var feedView: UIImageView!
    @IBOutlet weak var mailboxView: UIView!
    @IBOutlet weak var messageBGView: UIView!
    @IBOutlet weak var rescheduleView: UIImageView!
    @IBOutlet weak var listView: UIImageView!
    @IBOutlet weak var menuView: UIImageView!
    
    @IBOutlet weak var laterIcon: UIImageView!
    @IBOutlet weak var listIcon: UIImageView!
    @IBOutlet weak var deleteIcon: UIImageView!
    @IBOutlet weak var archiveIcon: UIImageView!
    
    @IBOutlet weak var resetButton: UIButton!
    

    
    var messageViewOriginalCenter: CGPoint!
    
    var messageStartingX: CGFloat!
    var messageStartingXPanBegan: CGFloat!
    var messageFinalX: CGFloat!
    
    var mailboxViewStartingX: CGFloat!
    var mailboxViewStartingXPanBegan: CGFloat!
    var mailboxViewFinalX: CGFloat!
    
    var iconBuffer: CGFloat!
    var laterIconX: CGFloat!
    var archiveIconX: CGFloat!
    
    var bgYellow = UIColor(red: 0.98, green: 0.83, blue: 0.2, alpha: 1.0) //yellow
    var bgBrown = UIColor(red: 0.85, green: 0.65, blue: 0.46, alpha: 1.0)
    var bgGreen = UIColor(red: 0.43, green: 0.85, blue: 0.38, alpha: 1.0)
    var bgRed = UIColor(red: 0.92, green: 0.32, blue: 0.2, alpha: 1.0)
    var bgGray = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        scrollView.contentSize = CGSize(width: 320, height: 1390)
        
        messageStartingX = messageView.frame.origin.x
        mailboxViewStartingX = mailboxView.frame.origin.x

        laterIconX = laterIcon.frame.origin.x
        archiveIconX = archiveIcon.frame.origin.x
        
        
        // add edge pan gesture by code because dragging in the object doesn't work for some reason
        var edgeGesture = UIScreenEdgePanGestureRecognizer(target: self, action: "onEdgePan:")
        edgeGesture.edges = UIRectEdge.Left
        mailboxView.addGestureRecognizer(edgeGesture)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    // PAN ON MESSAGE AT THE TOP 
    
    @IBAction func didPanMessage(sender: UIPanGestureRecognizer) {
        var translation = sender.translationInView(view)
        var location = sender.locationInView(view)
        var velocity = sender.velocityInView(view)
        
        if (sender.state == UIGestureRecognizerState.Began){
            messageStartingXPanBegan = messageView.frame.origin.x
            
            laterIcon.alpha = 0
            archiveIcon.alpha = 0
            
            
        } else if (sender.state == UIGestureRecognizerState.Changed) {
            
            messageFinalX = messageStartingXPanBegan + translation.x
            messageView.frame.origin.x = messageFinalX
            
            // short swipe left, show yellow on the right
            if messageFinalX <= -60 && messageFinalX >= -260
            {
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.messageBGView.backgroundColor = self.bgYellow
                    self.laterIcon.alpha = 1
                    self.laterIcon.frame.origin.x = self.laterIconX + self.messageFinalX + 50
                    self.laterIcon.image = UIImage(named: "later_icon")
                })
                
            }
                
           // long swipe left, show brown on the right
            else if messageFinalX <= -260
            {
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.messageBGView.backgroundColor = self.bgBrown
                    self.laterIcon.alpha = 1
                    self.laterIcon.image = UIImage(named: "list_icon") // change later icon image to list icon image
                })
            }
                
           // short swipe right, show buttons on the left
            else if messageFinalX >= 60 && messageFinalX <= 260
            {
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.messageBGView.backgroundColor = self.bgGreen
                    self.archiveIcon.alpha = 1
                    self.archiveIcon.frame.origin.x = self.archiveIconX + self.messageFinalX - 50
                    self.archiveIcon.image = UIImage(named: "archive_icon")
                })
            }
                
            // long swipe right, show buttons on the left
            else if messageFinalX >= 260
            {
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.messageBGView.backgroundColor = self.bgRed
                    self.archiveIcon.alpha = 1
                    self.archiveIcon.image = UIImage(named: "delete_icon") // change archive icon image to delete icon image
                })
            }
                
            // did not swipe far enough, reset to center
            else
            {
                messageBGView.backgroundColor = self.bgGray
                // use translate to figure out how much is visible, turn into a fraction to get opacity on icon
                laterIcon.alpha = -(translation.x)*0.01
                archiveIcon.alpha = (translation.x)*0.01
                //println("\(archiveIcon.alpha)")
            }
            
            
            
        } else if (sender.state == UIGestureRecognizerState.Ended) {

           
            // when letting go on short left swipe, extend yellow and show reschedule screen
            if messageFinalX <= -60 && messageFinalX >= -260
            {
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.revealAllLeft ()
                    self.rescheduleView.alpha = 1
                })
            }
            
            
            // when letting go on long left swipe, extend brown and show list screen
            else if messageFinalX <= -260
            {
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.revealAllLeft ()
                    self.listView.alpha = 1
                })
            }
                
            // when letting go on short right swipe, extend green and show reschedule screen
            else if messageFinalX >= 60 && messageFinalX <= 260
            {
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.revealAllRight()
                })
                {
                    // after the reveal animation is done, then do the collapse
                    (finished: Bool) -> Void in
                    self.collapseMessageView()
                }
                
            }

                
            // long swipe right, show buttons on the left
            else if messageFinalX >= 260
            {
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.revealAllRight()
                })
                {
                        (finished: Bool) -> Void in
                        self.collapseMessageView()
                }
            }
                
            
            // did not swipe far enough, reset to center
            else
            {
                resetAll()
            }
            
        }
    }

 
    
    

    
    @IBAction func didTapReset(sender: UIButton) {
        resetAll()
    }

    @IBAction func onTapReschedule(sender:
        UITapGestureRecognizer)
    {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.rescheduleView.alpha = 0
            })
        collapseMessageView()
    }
    
    @IBAction func onListTap(sender: AnyObject) {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.listView.alpha = 0
        })
        collapseMessageView()
    }
    
    
    
    
    
// FUNCTIONS //
    
    func revealAllLeft ()
    {
        self.messageView.frame.origin.x = -320
        self.laterIcon.frame.origin.x = 20
        self.archiveIcon.alpha = 0
    }
    
    
    func revealAllRight ()
    {
        self.messageView.frame.origin.x = 320
        self.archiveIcon.frame.origin.x = 290
        self.laterIcon.alpha = 0
    }
    
    
    func collapseMessageView()
    {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.messageBGView.frame.origin.y = -86
            self.feedView.frame.origin.y = self.feedView.frame.origin.y - self.messageBGView.frame.height
            self.resetButton.alpha = 1
        })
    }
    
    
    func resetAll()
    {
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.messageBGView.frame.origin.y = 79
            self.feedView.frame.origin.y = 165
            self.messageView.frame.origin.x = 0
            self.rescheduleView.alpha = 0
            self.listView.alpha = 0
            self.resetButton.alpha = 0
        })
    }
    
    
 
// EDGE PAN -- this should actually be a pan gesture, not an edge pan since once the mailbox view is moved, it's no longer an edge and thus can't be panned back.
    func onEdgePan(sender: UIScreenEdgePanGestureRecognizer)
    {
        var translation = sender.translationInView(view)
        var location = sender.locationInView(view)
        var velocity = sender.velocityInView(view)
        
        if (sender.state == UIGestureRecognizerState.Began)
        {
            mailboxViewStartingXPanBegan = mailboxView.frame.origin.x
        } else if (sender.state == UIGestureRecognizerState.Changed)
        {
            mailboxViewFinalX = mailboxViewStartingXPanBegan + translation.x
            mailboxView.frame.origin.x = mailboxViewFinalX

        } else if (sender.state == UIGestureRecognizerState.Ended)
        {
            if (velocity.x > 0)
            {
                mailboxView.frame.origin.x = 300
            }
            else
            {
                mailboxViewFinalX = mailboxViewStartingX
            }
        }
    }
 


}

