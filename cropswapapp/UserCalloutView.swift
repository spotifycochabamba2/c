//
//  UserCalloutView.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 6/22/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import Mapbox

class UserCalloutView: UIView, MGLCalloutView {
  /**
   Dismisses the callout view.
   */
  public func dismissCallout(animated: Bool) {
    if (superview != nil) {
      if animated {
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
          self?.alpha = 0
          }, completion: { [weak self] _ in
            self?.removeFromSuperview()
          })
      } else {
        removeFromSuperview()
      }
    }
  }


  /**
   An object conforming to the `MGLAnnotation` protocol whose details this callout
   view displays.
   */
  public var representedObject: MGLAnnotation
  public var leftAccessoryView = UIView() /* unused */
  var rightAccessoryView = UIView() /* unused */
  
  weak var delegate: MGLCalloutViewDelegate?
  
  let tipHeight: CGFloat = 10.0
  let tipWidth: CGFloat = 20.0
  
  var tapGesture: UITapGestureRecognizer!
  
  func isCalloutTappable() -> Bool {
    if let delegate = delegate {
      if delegate.responds(to: #selector(MGLCalloutViewDelegate.calloutViewShouldHighlight)) {
        return delegate.calloutViewShouldHighlight!(self)
      }
    }
    return false
  }
  
  func calloutTapped() {
    
    let userAnnotation = representedObject as? UserAnnotationView
    
    
    if isCalloutTappable() && delegate!.responds(to: #selector(MGLCalloutViewDelegate.calloutViewTapped)) {
      delegate!.calloutViewTapped!(self)
    }
  }
  
  required init(representedObject: MGLAnnotation) {
    self.representedObject = representedObject
    
    super.init(frame: .zero)
    
    tapGesture = UITapGestureRecognizer(target: self, action: #selector(calloutTapped))
    tapGesture.numberOfTapsRequired = 1
    tapGesture.numberOfTouchesRequired = 1
    
    addGestureRecognizer(tapGesture)
    
    backgroundColor = .clear
  }
  
  func viewTapped() {
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension UserCalloutView {
  @objc(presentCalloutFromRect:inView:constrainedToView:animated:) func presentCallout(from rect: CGRect, in view: UIView, constrainedTo constrainedView: UIView, animated: Bool) {
    view.addSubview(self)

    let customViewWidth: CGFloat = 200.0
    let customViewHeight: CGFloat = 100.0

    let x = rect.origin.x - ((abs(customViewWidth - rect.size.width)) / 2)
    let y = rect.origin.y - customViewHeight
    
    frame = CGRect(
      x: x,
      y: y,
      width: customViewWidth,
      height: customViewHeight
    )
    
    
    
    let baseStackView = createBaseStackView(parentView: self)
//    baseStackView.translatesAutoresizingMaskIntoConstraints = false
    
//    let imageStackView = createImageStackView()
    
    let usernameLabel = createUsernameLabel(parentView: baseStackView)
    let loadingLabel = createLoadingLabel()
    let backgroundView = createBackgroundView(andAddTo: baseStackView)
    
    usernameLabel.text = (representedObject as? UserPointAnnotation)?.userName
    loadingLabel.text = "Loading..."
    
    let imageStackView = createImageStackView(andAddTo: backgroundView)
    addLoadingLabelToImageStackView(loadingLabel, imageStackView)
//
//    loadingLabel.removeFromSuperview()
    
    let userId = (representedObject as? UserPointAnnotation)?.reuseIdentifier
    
    if let userId = userId {
      User.getProducesByUser(byUserId: userId, completion: { [weak self] (produces) in
        guard let this = self else {
          return
        }
        
        if produces.count > 0 {
          
          DispatchQueue.main.async {
            imageStackView.removeArrangedSubview(loadingLabel)
            loadingLabel.removeFromSuperview()
            baseStackView.distribution = .fill
          }
          
          if produces.count >= 3 {
            let firstProduce = produces[0]
            let secondProduce = produces[1]
            let thirdProduce = produces[2]
            
            let firstImageURLString = firstProduce["firstPictureURL"] as? String
            let secondImageURLString = secondProduce["firstPictureURL"] as? String
            let thirdImageURLString = thirdProduce["firstPictureURL"] as? String
            
            DispatchQueue.main.async {
              let firstImageView = this.createFirstImageView(andAddTo: imageStackView)
              firstImageView.contentMode = .scaleAspectFill
              let secondImageView = this.createFirstImageView(andAddTo: imageStackView)
              secondImageView.contentMode = .scaleAspectFill
              
              let thirdImageView = this.createFirstImageView(andAddTo: imageStackView)
              thirdImageView.contentMode = .scaleAspectFill
              
              if let url = URL(string: firstImageURLString ?? "") {
                firstImageView.sd_setImage(with: url)
              }
              
              if let url = URL(string: secondImageURLString ?? "") {
                secondImageView.sd_setImage(with: url)
              }
              
              if let url = URL(string: thirdImageURLString ?? "") {
                thirdImageView.sd_setImage(with: url)
              }
            }
          } else if produces.count  == 2 {
            let firstProduce = produces[0]
            let secondProduce = produces[1]
            
            let firstImageURLString = firstProduce["firstPictureURL"] as? String
            let secondImageURLString = secondProduce["firstPictureURL"] as? String
            
            DispatchQueue.main.async {
              let firstImageView = this.createFirstImageView(andAddTo: imageStackView)
              let secondImageView = this.createFirstImageView(andAddTo: imageStackView)
            
              if let url = URL(string: firstImageURLString ?? "") {
                firstImageView.sd_setImage(with: url)
              }
              
              if let url = URL(string: secondImageURLString ?? "") {
                secondImageView.sd_setImage(with: url)
              }
            }
          } else {
            let firstProduce = produces[0]
            let firstImageURLString = firstProduce["firstPictureURL"] as? String
            
            DispatchQueue.main.async {
              let firstImageView = this.createFirstImageView(andAddTo: imageStackView)
              
              if let url = URL(string: firstImageURLString ?? "") {
                firstImageView.sd_setImage(with: url)
              }
            }
          }
        } else {
          loadingLabel.text = "No products added."
        }
      })
    } else {
      
    }
    
    

    
//    let firstImageView = createImageView(imageStackView)
//    let secondImageView = createImageView(imageStackView)
//    let thirdImageView = createImageView(imageStackView)
    
    
//    secondImageView.isHidden = true
    
//    imageStackView.addArrangedSubview(firstImageView)
//    imageStackView.addArrangedSubview(secondImageView)
//    imageStackView.addArrangedSubview(thirdImageView)
    
    
//    
//    let deleteMeView = UIView()
//    deleteMeView.backgroundColor = .yellow
////    deleteMeView.heightAnchor.constraint(equalToConstant: 10).isActive = true
    
//    baseStackView.addArrangedSubview(imageStackView)
    
//    addSubview(baseStackView)
  }
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    let fillColor : UIColor = .white
    
    let tipLeft = rect.origin.x + (rect.size.width / 2.0) - (tipWidth / 2.0)
    let tipBottom = CGPoint(x: rect.origin.x + (rect.size.width / 2.0), y: rect.origin.y + rect.size.height)
    let heightWithoutTip = rect.size.height - tipHeight
    
    let currentContext = UIGraphicsGetCurrentContext()!
    
    let tipPath = CGMutablePath()
    tipPath.move(to: CGPoint(x: tipLeft, y: heightWithoutTip))
    tipPath.addLine(to: CGPoint(x: tipBottom.x, y: tipBottom.y))
    tipPath.addLine(to: CGPoint(x: tipLeft + tipWidth, y: heightWithoutTip))
//
    tipPath.closeSubpath()
    
    fillColor.setFill()
    currentContext.addPath(tipPath)
    currentContext.fillPath()
  }
}

extension UserCalloutView {
  
  func createLoadingLabel() -> UILabel {
    let label = UILabel()
    label.font = UIFont(name: "Montserrat-Regular", size: 14)
    label.textColor = .black
    label.textAlignment = .center
    label.backgroundColor = .clear
    
    return label
  }
  
  func createUsernameLabel(parentView: UIStackView) -> UILabel {
    let label = UILabel()
    label.font = UIFont(name: "Montserrat-Regular", size: 14)
    label.textColor = .black
    label.textAlignment = .center
    label.backgroundColor = .clear
    
    parentView.addArrangedSubview(label)
    
//    label.leftAnchor.constraint(equalTo: parentView.leftAnchor).isActive = true
//    label.rightAnchor.constraint(equalTo: parentView.rightAnchor).isActive = true
//    
//    label.translatesAutoresizingMaskIntoConstraints = false
    
    return label
  }
//  
//  func createImageStackView() -> UIStackView {
//    let stackView = UIStackView()
//    stackView.axis = .horizontal
//    stackView.alignment = .fill
//    stackView.distribution = .equalSpacing
//    stackView.spacing = 10
//    
//    stackView.translatesAutoresizingMaskIntoConstraints = false
//    
//    return stackView
//  }
//  
//  func createImageView(_ parentView: UIStackView) -> UIImageView {
//    let image = UIImageView()
//    parentView.addArrangedSubview(image)
//    image.backgroundColor = .purple
//    image.widthAnchor.constraint(equalToConstant: 60).isActive = true
//    image.translatesAutoresizingMaskIntoConstraints = false
//    
//    image.topAnchor.constraint(equalTo: parentView.topAnchor).isActive = true
//    image.bottomAnchor.constraint(equalTo: parentView.bottomAnchor).isActive = true
//    
//    return image
//  }
//  
  
  func createFirstImageView(andAddTo parentStackView: UIStackView) -> UIImageViewCircular {
    let imageView = UIImageViewCircular()
    
    parentStackView.addArrangedSubview(imageView)
    
    imageView.backgroundColor = UIColor.lightGray
    imageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
    imageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
//    imageView.topAnchor.constraint(equalTo: parentView.topAnchor, constant: 0).isActive = true
//    imageView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: 0).isActive = true
//    imageView.centerXAnchor.constraint(equalTo: parentView.centerXAnchor, constant: 0).isActive = true
    
    imageView.translatesAutoresizingMaskIntoConstraints = false
    
    return imageView
  }
  

  func createImageStackView(
    andAddTo parentView: UIView
  ) -> UIStackView {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.alignment = .fill
    stackView.distribution = .fill
    stackView.spacing = 10
    
    parentView.addSubview(stackView)
    stackView.translatesAutoresizingMaskIntoConstraints = false
    
    stackView.topAnchor.constraint(equalTo: parentView.topAnchor, constant: 0).isActive = true
    stackView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: 0).isActive = true
    stackView.centerXAnchor.constraint(equalTo: parentView.centerXAnchor, constant: 0).isActive = true
    
    return stackView
  }
  
  func createBackgroundView(
    andAddTo parentView: UIStackView
  ) -> UIView {
    let view = UIView()
    view.backgroundColor = .clear
    
    parentView.addArrangedSubview(view)
    
    return view
  }
  
  func addLoadingLabelToImageStackView(_ label: UILabel, _ stackView: UIStackView) {
    stackView.addArrangedSubview(label)
  }
  
  func createBaseStackView(parentView: UIView) -> UIStackView {
    let view = UIView()
    view.backgroundColor = UIColor.white
    view.makeMeBordered(color: .clear, cornerRadius: 4)
    parentView.addSubview(view)
    
    view.topAnchor.constraint(equalTo: parentView.topAnchor, constant: 0).isActive = true
    view.bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: -10).isActive = true
    view.rightAnchor.constraint(equalTo: parentView.rightAnchor, constant: 0).isActive = true
    view.leftAnchor.constraint(equalTo: parentView.leftAnchor, constant: 0).isActive = true
    view.translatesAutoresizingMaskIntoConstraints = false
    
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.alignment = .fill
//    stackView.distribution = .fill
    stackView.distribution = .fillEqually
    stackView.spacing = 10
    
    view.addSubview(stackView)
    
    let topLayoutConstraint = NSLayoutConstraint(
      item: stackView,
      attribute: .top,
      relatedBy: .equal,
      toItem: view,
      attribute: .top,
      multiplier: 1,
      constant: 0
    )
    
    let rightLayoutConstraint = NSLayoutConstraint(
      item: stackView,
      attribute: .right,
      relatedBy: .equal,
      toItem: view,
      attribute: .right,
      multiplier: 1,
      constant: 0
    )
    
    let bottomLayoutConstraint = NSLayoutConstraint(
      item: stackView,
      attribute: .bottom,
      relatedBy: .equal,
      toItem: view,
      attribute: .bottom,
      multiplier: 1,
      constant: -5
    )
    
    let leftLayoutConstraint = NSLayoutConstraint(
      item: stackView,
      attribute: .left,
      relatedBy: .equal,
      toItem: view,
      attribute: .left,
      multiplier: 1,
      constant: 0
    )
    
    parentView.addConstraints([
      topLayoutConstraint,
      rightLayoutConstraint,
      bottomLayoutConstraint,
      leftLayoutConstraint
    ])
    
    NSLayoutConstraint.activate([
      topLayoutConstraint,
      rightLayoutConstraint,
      bottomLayoutConstraint,
      leftLayoutConstraint
    ])
    
    stackView.translatesAutoresizingMaskIntoConstraints = false
    
    return stackView
  }
  
}








































