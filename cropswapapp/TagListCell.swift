//
//  TagListCell.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 6/13/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit


public class TagListCell: UITableViewCell {
  static let identifier = "tagListCellId"
  @IBOutlet weak var tagListNameLabel: UILabel!
  @IBOutlet weak var tagListSelectedStackView: UIStackView!
  
  var tagsAlreadySelected: [String: Any]!
  
//  var tagsAlreadySelected 
  
  var labels = [UILabel]()
  var views = [UIView]()
  var imageViews = [UIImageView]()
  
  var tagList: [String: Any]? {
    didSet {
      if let tagList = tagList {
        if let keyGroup = tagList.keys.first {
          tagListNameLabel.text =  Constants.Tag.tagGroupNames[keyGroup]
          if let tags = tagList[keyGroup] as? [String: Any] {
            for (keyTag, _) in tags {
              if let tagsSelected = tagsAlreadySelected[keyGroup] as? [String: Any],
                 let tagItemSelected = tagsSelected[keyTag] as? [String: Any],
                 let tagName = tagItemSelected["name"] as? String
              {
                add(name: tagName)
              }
            }
          }
        }
      }
    }
  }
}

extension TagListCell {
  public override func prepareForReuse() {
    super.prepareForReuse()
    
    tagListNameLabel.text = ""
//    labels.forEach {
//      tagListSelectedStackView.removeArrangedSubview($0)
//      $0.removeFromSuperview()
//    }
//    labels.removeAll()
    
    views.forEach {
      tagListSelectedStackView.removeArrangedSubview($0)
      $0.removeFromSuperview()
    }
    views.removeAll()
    
//    tagListSelectedStackView.layoutIfNeeded()
  }
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    
  }
  
  func add(name: String) {
    //working
    let label = UILabel()
    label.text = name//20
    label.font = UIFont(name: "Montserrat-Light", size: 12)
    label.translatesAutoresizingMaskIntoConstraints = false
//    label.heightAnchor.constraint(equalToConstant: 20).isActive = true
//    labels.append(label)
//    tagListSelectedStackView.addArrangedSubview(label)
    //tagListSelectedStackView.translatesAutoresizingMaskIntoConstraints = false
    //end working
    
    let imageView = UIImageView(image: UIImage(named: "bullet-point-icon"))
    imageView.widthAnchor.constraint(equalToConstant: 8).isActive = true
    imageView.heightAnchor.constraint(equalToConstant: 6).isActive = true
    imageView.translatesAutoresizingMaskIntoConstraints = false
//    imageViews.append(imageView)
//
    let view = UIView()
    view.heightAnchor.constraint(equalToConstant: 20).isActive = true
    views.append(view)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(imageView)
    view.addSubview(label)
    
    label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8).isActive = true
    label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    
    imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true
    imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    
    tagListSelectedStackView.addArrangedSubview(view)
//    tagListSelectedStackView.translatesAutoresizingMaskIntoConstraints = false
  }
}











