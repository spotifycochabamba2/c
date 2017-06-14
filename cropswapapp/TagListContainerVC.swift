//
//  TagListContainerVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 6/14/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

public class TagsListContainerVC: UIViewController {
  var tagsAlreadySelected = [String: Any]()
  var child: TagListChildVC?
  @IBOutlet weak var acceptButton: UIButton! {
    didSet {
      acceptButton.makeMeBordered(borderWidth: 1, cornerRadius: 3)
    }
  }
  
  @IBOutlet weak var bottomBarView: UIView!
  
  var didSelectTags: ([String: Any]) -> Void = { _ in }
  
  @IBAction func acceptButtonTouched() {
    if let child = child {
      didSelectTags(child.tagsAlreadySelected)
    }
    
    dismiss(animated: true) {
//      DispatchQueue.main.async {
//        if let this = self {
//          this.didSelectTags(this.tagsAlreadySelected)
//        }
//      }
    }
  }
  
  public override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    bottomBarView.layer.shadowOffset = CGSize(width: 0, height: 0);
    bottomBarView.layer.shadowRadius = 2;
    bottomBarView.layer.shadowColor = UIColor.black.cgColor
    bottomBarView.layer.shadowOpacity = 0.3;
  }
  
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setNavHeaderTitle(title: "Tags", color: UIColor.black)
    
    let leftButtonIcon = setNavIcon(imageName: "back-icon-1", size: CGSize(width: 40, height: 47), position: .left)
    leftButtonIcon.addTarget(self, action: #selector(backButtonTouched), for: .touchUpInside)
  }
  
  public func backButtonTouched() {
    dismiss(animated: true)
  }
}

extension TagsListContainerVC {
  public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let vc = segue.destination as? TagListChildVC
    vc?.tagsAlreadySelected = tagsAlreadySelected
    
    child = vc
  }
}
