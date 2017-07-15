//
//  WallContainerVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 7/6/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

public class WallContainerVC: UIViewController {
  
  var wallOwnerId: String?
  
  public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == Storyboard.WallToPost {
      
      let nc = segue.destination as? UINavigationController
      let vc = nc?.viewControllers.first as? WallPostVC
      
      vc?.currentUserId = User.currentUser?.uid
      vc?.wallOwnerId = wallOwnerId
    } else if segue.identifier == Storyboard.WallContainerToWallChild {
      
      let vc = segue.destination as? WallVC2
      vc?.wallOwnerId = wallOwnerId
    } 
  }
  
  @IBAction func openPostButtonTouched() {
    performSegue(withIdentifier: Storyboard.WallToPost, sender: nil)
  }
  
}
























