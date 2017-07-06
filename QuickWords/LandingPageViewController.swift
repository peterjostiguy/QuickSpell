//
//  LandingPageViewController.swift
//  QuickWords
//
//  Created by Peter Ostiguy on 9/19/16.
//  Copyright © 2016 Peter Ostiguy. All rights reserved.
//

import UIKit
import GameplayKit
import GameKit;



class LandingPageViewController: UIViewController, GKGameCenterControllerDelegate, GKTurnBasedMatchmakerViewControllerDelegate {
    
    @IBOutlet weak var logoButton: UIButton!

    @IBOutlet weak var logoPlaceholder: UIImageView!
    @IBOutlet weak var leaderButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBAction func showLeaderboard(_ sender: AnyObject) {
        showLeader()
    }
    
    func saveHighscore(_ score:Int) {
        
        //check if user is signed in
        if GKLocalPlayer.localPlayer().isAuthenticated {
            
            
            let scoreReporter = GKScore(leaderboardIdentifier: "LightningWordLeaderboard") //leaderboard id here
            
            scoreReporter.value = Int64(score) //score variable here (same as above)
            
            let scoreArray: [GKScore] = [scoreReporter]
            
            GKScore.report(scoreArray, withCompletionHandler: {(error : NSError?) -> Void in
                if error != nil {
                    print("error")
                }
            } as! (Error?) -> Void)
            
        }
        
    }
    
    func showLeader() {
      //  let vc = self.view?.window?.rootViewController
        let gc = GKGameCenterViewController()
        gc.gameCenterDelegate = self
        self.present(gc, animated: true, completion: nil)
    }
    

    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController)
    {
    gameCenterViewController.dismiss(animated: true, completion: nil)
}

    
    @IBAction func multiplayerButton(_ sender: AnyObject) {
        let r = GKMatchRequest()
        r.minPlayers = 2
        r.maxPlayers = 2
        r.defaultNumberOfPlayers = 2
        let vc = GKTurnBasedMatchmakerViewController(
            matchRequest: r
        )
        vc.turnBasedMatchmakerDelegate = self
        self.present(vc, animated: true, completion: nil)
  //      self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func turnBasedMatchmakerViewController(_ viewController: GKTurnBasedMatchmakerViewController, didFailWithError error: Error) {
        print(error)
    }
    
    func turnBasedMatchmakerViewControllerWasCancelled(_ viewController: GKTurnBasedMatchmakerViewController) {}
 //       let vc = GKTurnBasedMatchmakerViewController(
 //       )
 //       vc.turnBasedMatchmakerDelegate = self
 //       self.presentViewController(vc, animated: true, completion: nil)
 //       self.dismissViewControllerAnimated(true, completion: nil)
  // }
    
  //  func turnBasedMatchmakerViewController(viewController: GKTurnBasedMatchmakerViewController, didFindMatch match: GKTurnBasedMatch) {
  //      let vc = GKTurnBasedMatchmakerViewController()
  //      vc.turnBasedMatchmakerDelegate = self
  //   self.presentViewController(vc, animated: true, completion: nil)
  //      self.dismissViewControllerAnimated(true, completion: nil)
  //      print("match found!")
  //  }
    
    func updateMatchData(_ matchData: GKTurnBasedMatch) {
        print("HELLO!!!!")
        print(matchData.participants)
    //currentMatch?.endTurnWithNextParticipants(
    //[opponent()],
    //turnTimeout: GKTurnTimeoutDefault,
   // matchData: matchData,
  //  completionHandler: nil
  //  )
        
   }
    
    func turnBasedMatchmakerViewController(_ viewController: GKTurnBasedMatchmakerViewController, didFind match: GKTurnBasedMatch) {
//        dismissViewControllerAnimated(true) { self.updateMatchData(match) }
    }
    
    func player(_ player: GKPlayer, receivedTurnEventForMatch match: GKTurnBasedMatch, didBecomeActive: Bool) {
 //       updateMatchData(match)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authenticateLocalPlayer()
        startButton.setImage(UIImage(named: "Backgrounds/Start.png"), for: UIControlState())
        leaderButton.setImage(UIImage(named: "Backgrounds/Leaders.png"), for: UIControlState())
        logoButton.setImage(UIImage(named: "Backgrounds/logo.png"), for: UIControlState())
    }
    


    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func authenticateLocalPlayer(){
        
        let localPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {(viewController, error) -> Void in
            
            if (viewController != nil) {
                self.present(viewController!, animated: true, completion: nil)
            }
                
            else {
                print((GKLocalPlayer.localPlayer().isAuthenticated))
            }
        }
        
    }

//     MARK: - Navigation

 //   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        segue.destinationViewController
//    }


}
