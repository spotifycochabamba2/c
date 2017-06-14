//
//  ChooseTagsVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 6/13/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit

public class ChooseTagsContainerVC: UIViewController {
  var tagListKey: String?
  var tagList: [String: Any]?
  var tagsSelected = [String: Any]()
  var child: ChooseTagsChildVC?
  
  @IBOutlet weak var bottomBarView: UIView!
  
  @IBOutlet weak var addButton: UIButton! {
    didSet {
      addButton.makeMeBordered(borderWidth: 1, cornerRadius: 3)
    }
  }
  
    var didAddItems: (String, [String: Any]) -> Void = { _, _ in }
  
  @IBAction func addButtonTouched(_ sender: AnyObject) {
    let result = child?.getTagsSelected()
    tagsSelected = [String: Any]()

    if let tags = result?.tags {
      tags.forEach {
        if let id = $0["id"] as? String {
          tagsSelected[id] = $0
        }
      }
    }
    _ = navigationController?.popViewController(animated: true)
    didAddItems(tagListKey ?? "", tagsSelected)
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
    
    automaticallyAdjustsScrollViewInsets = false
    
    setNavHeaderTitle(title: Constants.Tag.tagGroupNames[tagListKey ?? ""] ?? "", color: UIColor.black)
    
    let leftButtonIcon = setNavIcon(imageName: "back-icon-1", size: CGSize(width: 40, height: 47), position: .left)
    leftButtonIcon.addTarget(self, action: #selector(backButtonTouched), for: .touchUpInside)
  }
  
  public func backButtonTouched() {
    _ = navigationController?.popViewController(animated: true)
  }
  
  public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let vc = segue.destination as? ChooseTagsChildVC
    child = vc
    
    vc?.tagsDictionary = tagList
    vc?.tagsSelected = tagsSelected
    vc?.tagListKey = tagListKey
  }
}









































