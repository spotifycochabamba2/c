//
//  TermsConditionsVC.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 7/24/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import UIKit
import BonMot

public class TermsConditionsVC: UIViewController {
  
  var comesFromSettings = false
  
  @IBOutlet weak var acceptView: UIView!
  
  @IBOutlet weak var acceptButton: UIButton!
  
  @IBOutlet weak var textView: UITextView!
  
  @IBOutlet weak var backgroundView: UIView!
  @IBOutlet weak var upperView: UIView!
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .clear
    
    backgroundView.backgroundColor = .white
    backgroundView.alpha = 0.8
    
    textView.isScrollEnabled = false
    
    let boldStyle = StringStyle(
      .font(Constants.Fonts.montserratBoldFont!)
    )
    
//    let lightStyle = StringStyle(
//      .font(Constants.Fonts.montserratLightFont!)
//    )
    
    let privacyStyle = StringStyle(
      .color(UIColor.black),
      .font(Constants.Fonts.montserratLightFont!),
      .xmlRules([
        XMLStyleRule.style("bold", boldStyle)
        ])
    )
    
    let string1 = NSAttributedString.composed(of: [
      "<bold>1. Legal Information</bold>\n\n1.1. This document is intended to inform you about the Terms and Conditions that regulate the use of the website www.cropswapapp.com (hereinafter, the \"Website\") and the Application Cropswap (hereinafter, the \"Application\").\n\n1.2. The owner of both the Website and the Application is Cropswap Inc (hereinafter \"Cropswap\", \"us\" or \"we\"), with registered address at 19802 Victory Blvd, Woodland Hills, CA 91367, holder of EIN number 81-1382368. The service is provided by Cropswap Inc.\n\n1.3. Cropswap is a company incorporated under the laws of the United States of America, registered in the Delaware.\n\n1.4. You can contact us at info@cropswapapp.com whenever you want. \n\n<bold>2. Object </bold>\n\n2.1. These Terms and Conditions govern the use of the Application in which Cropswap offers, as social marketplace, a platform to Users willing to buy, trade, or sell home-grown produce, mediating in the sale of these products. The information regarding the treatment of your personal data is located in the \"Privacy Policy\".\n\n2.2. The Application may be integrated in the social network Instagram. Instagram Inc. is an independent company with regard to Cropswap, with its own privacy policy established and managed by Instagram.\n\n<bold>3. Access and acceptance of the Terms and Conditions</bold>\n\n3.1. By entering, executing using, downloading, accessing or using the Application or the Website you will automatically be considered a User (hereinafter the \"User\" or \"you\") which requires the full acceptance of each and every provision included in this Terms and Conditions, in the version published by Cropswap at the time you access or use the Website or the Application.\n\nConsequently, please, read carefully all the legal texts applicable to the use of the Website and the Application each and every time you intend to use them.\n\n3.2. If you do not wish to accept the present Terms and Conditions, please, do not use the Services and uninstall the Application from your device.\n\n3.3. The use of certain services offered on the Website or in the Application may be subject to Specific Terms and Conditions that, depending on the case, may substitute complete and/or modify this document. Therefore, prior to the use of such Services, you must carefully read the corresponding Specific Terms and Conditions.\n\n3.4. Cropswap reserves the right to modify, at any time and providing notice, this Terms and Conditions, so you are obliged to periodically review this Terms and to comply with the obligations set out in the current version in each moment.\n\n<bold>4. Required Age</bold>\n\n4.1. Both the Website and the Application are intended to be used by adults, as defined under any applicable law in each specific case. If you are not an adult, you are not authorized to download the Application, register and create an account with us. If you are a minor, you need the permission of your legal representatives in order to use the Service. In this case, the legal representative is liable for any acts committed by the minor. Please, if you are A minor and you do not have your legal representative’s permission, stop using the Website and uninstall the Application.\n\n4.2. You further warrant that you are an adult under the applicable law. In the event that the information you provide in this regard is not truthful, Cropswap shall not be liable as it cannot certainty verify the age of the Users.\n\n4.3. Cropswap may contact you at any time requiring you to prove your age using a photocopy of an identity card or equivalent. If you deny providing identification, Cropswap reserves the right to close your user profile and you will not be able to continue using the service or the Application.\n\n4.4. To sell or purchase via the Application any type of product, users are minors under applicable law will need the specific permission of their legal representatives.\n\n<bold>5. Creation of an account</bold>\n\n5.1. To use or access to certain functionalities of the Application you need to register, either using your e-mail address or your Instagram account. In case you use a social network mentioned above, you authorize Cropswap to access and use certain information depending on the privacy settings that you have selected in the corresponding social network.\n\n5.2. You agree to provide accurate, current, and complete Member account information about you as may be prompted by the registration and/or login form on the Application.\n\n<bold>6. Security of the account</bold>\n\nBy opening an account you accept and assume all liability that may arise in any activity that occurs under your username and password. You are responsible for maintaining the confidentiality of the password you designate during the registration process. You cannot share it with other people or perform acts that may diminish or undermine the security of your account. If you have knowledge that your password was compromised, you should inform us immediately in order to recover your account.\n\n<bold>7. Installation and running the Application</bold>\n\n7.1. Cropswap grants you a license for installing and running the Application.\n\n7.2. The installation and execution of the Application is free.\n\n7.3. You must accept the permissions for installation and execution of the Application. From time to time, Cropswap may request the granting of additional permissions to perform certain actions or enjoy certain functionalities. The lack of acceptance of some of the permits necessary for the proper operation of the Application may result in the suspension of the Services or impossibility of using the Application.\n\n<bold>8. Features of the Service</bold>\n\n8.1. The service will allow different actions, including:\n\n8.1. The service will allow different actions, including:\n\n8.1.1. Sharing with the rest of Users of Cropswap information, images, photos as well as other data or personal information.\n\n8.1.2. Putting products on sale as a seller User and making offers as a buyer User in order to buy or negotiate price products.\n\n8.1.3. Interacting with other users of Cropswap though a private chat and other ways to be implemented in the future.\n\n8.1.4. Sharing product offers in other platforms or social networks other than Cropswap.\n\n<bold>9. Intellectual property rights</bold>\n\n9.1. Cropswap Inc is the holder of the rights of intellectual and industrial property, or has obtained the necessary authorizations or licenses for its exploitation, associated with the application, the software, its database, the trademarks and any other distinctive signs, the content posted and the rest of works and inventions or content related to the Application and the technology associated with it.\n\n9.2. The contents of the Application, including the design, applications, text, images and source code, are protected by intellectual and industrial property rights.\n\n9.3. The contents of this Application, the database of users, the screenshots or the Website may not be used, reproduced, broadcasted, copied, processed or transmitted in any form without the prior permission in writing of Cropswap.\n\n9.4. Cropswap assumes no responsibility for the intellectual or industrial property rights of the content that seller Users include in the offerings of its products.\n\n<bold>10. Waiver of responsibility</bold>\n\n10.1. Cropswap is a platform that brings together buyers and sellers of home-grown produce. Cropswap is not the owner and has no control of the items for sale or sold through its platform, unless otherwise stated, and is not a party to the transaction of the sale carried out exclusively between buyers and sellers and does not review the products that Users provide though the Application. As a consequence, Cropswap shall not be responsible, either directly or indirectly, for any disagreement between the parties.\n\n10.2. All information of the products published on the Application or the Website has been built and published by the USER which is selling the product. Consequently, Cropswap cannot guarantee the quality of the same, as well as the veracity of the images and/or descriptions published by the seller Users.\n\n10.3. Any claim or dispute that may arise between Users of the Service shall be settled by them, committing themselves to hold Cropswap harmless.\n\n10.4. Cropswap service is limited to employ the utmost diligence to ensure the proper technical functioning of the platform.\n\n10.5. Cropswap shall in no case be responsible for the content operation and/or data protection or other terms referred to in other web sites or applications that may be accessed by the inclusion of a link on the Service, or the content, services or products offered on the same, unless such sites are owned by Cropswap. The hyperlinks contained in the Website or in the Application may lead to third party web sites. Cropswap may incorporate them to facilitate the navigation of the User, assuming no responsibility for the content, information or services that may appear on those sites, which will be exclusively informative and in no case imply any relationship between the third party and Cropswap.\n\n10.6. Cropswap develops maximum diligence in the implementation of security measures, however assumes no responsibility or liability whatsoever with regard to the custody and proper use of the passwords for access to the WEB SITE, which will be the sole responsibility of the User.\n\n<bold>11. Warranty of products</bold>11.1. Cropswap does not assume any responsibility nor warrants the products sold by using the Cropswap Application The transaction takes places and is decided exclusively between the buyer and seller, and Cropswap only provides the use of the application.\n\n<bold>12. Exclusion of liability</bold>\n\n12.1. User access to the Website or Application does not imply for Cropswap the obligation to monitor the absence of viruses, worms, or any other harmful technical element. It is you, in any case, the sole responsible for making available the adequate tools for the detection of harmful computer programs.\n\n12.2. Cropswap is not responsible for any damages incurred in the software and computers of users or third parties during the use of the services offered on the Website or the Application.\n\n12.3. Cropswap shall not be liable for damages of any kind that you are caused to bring cause of faults or disconnections in telecommunication networks that produce the suspension, cancellation or interruption of service of the Website or the Application.\n\n<bold>13. Prohibited items</bold>\n\n13.1. Cropswap prohibits the listing or sale of any items that are illegal under any applicable law, statute, ordinance or regulation at a local, state, provincial, national or international level.\n\n13.2. Some examples of items that are not allowed:\n\n",
          "•",
          Tab.headIndent(14),
          "Photos that do not show the item clearly.\n",
          "•",
          Tab.headIndent(14),
          "Internet photos, i.e. you have not taken the picture yourself.\n",
          "•",
          Tab.headIndent(14),
          "Item infringes trademarks, copyrights or any other IP rights of third parties.\n",
          "•",
          Tab.headIndent(14),
          "Advertisements.\n",
          "•",
          Tab.headIndent(14),
          "Photo or text containing a reference to another website, app or merchant.\n",
          "•",
          Tab.headIndent(14),
          "Items that are defective or of poor quality.\n",
          "•",
          Tab.headIndent(14),
          "An item listed as \"free\" but is not intended to be given away.\n",
          "•",
          Tab.headIndent(14),
          "There is no realistic price set for the item.\n",
          "•",
          Tab.headIndent(14),
          "Duplicated listings\n",
          "•",
          Tab.headIndent(14),
          "Other items that are specifically prohibited include:\n",
          Tab.headIndent(14),
          "•",
          Tab.headIndent(14),
          "Alcoholic Beverages\n",
          Tab.headIndent(14),
          "•",
          Tab.headIndent(14),
          "Blood, Bodily Fluids and Body Parts\n",
          Tab.headIndent(14),
          "•",
          Tab.headIndent(14),
          "Burglary Tools\n",
          Tab.headIndent(14),
          "•",
          Tab.headIndent(14),
          "Controlled chemical substances (such as cadmium, mercury, acids)\n",
          Tab.headIndent(14),
          "•",
          Tab.headIndent(14),
          "Counterfeit currency, stamps or coins\n",
          Tab.headIndent(14),
          "•",
          Tab.headIndent(14),
          "Counterfeit Products\n",
          Tab.headIndent(14),
          "•",
          Tab.headIndent(14),
          "Databases containing personal data\n",
          Tab.headIndent(14),
          "•",
          Tab.headIndent(14),
          "Electronic Surveillance Equipment\n",
          Tab.headIndent(14),
          "•",
          Tab.headIndent(14),
          "Embargoed Goods\n",
          Tab.headIndent(14),
          "•",
          Tab.headIndent(14),
          "Government, official and Transit Uniforms, IDs and Licenses\n",
          Tab.headIndent(14),
          "•",
          Tab.headIndent(14),
          "Illegal Drugs and Drug Paraphernalia\n",
          Tab.headIndent(14),
          "•",
          Tab.headIndent(14),
          "All types of illegal services and products\n",
          Tab.headIndent(14),
          "•",
          Tab.headIndent(14),
          "Hacking tools\n",
          Tab.headIndent(14),
          "•",
          Tab.headIndent(14),
          "Hazardous Materials\n",
          Tab.headIndent(14),
          "•",
          Tab.headIndent(14),
          "Fireworks, Destructive Devices and Explosives\n",
          Tab.headIndent(14),
          "•",
          Tab.headIndent(14),
          "Identity Documents, Personal Financial Records and Personal Information (in any form, including mailing lists).\n",
          Tab.headIndent(14),
          "•",
          Tab.headIndent(14),
          "Items received through Government assistance\n",
          Tab.headIndent(14),
          "•",
          Tab.headIndent(14),
          "Items which encourage or facilitate illegal activity\n",
          Tab.headIndent(14),
          "•",
          Tab.headIndent(14),
          "Lottery Tickets, Sweepstakes Entries and Slot Machines\n",
          Tab.headIndent(14),
          "•",
          Tab.headIndent(14),
          "Obscene Material and all types of Pornography\n",
          Tab.headIndent(14),
          "•",
          Tab.headIndent(14),
          "All type of offensive material\n",
          Tab.headIndent(14),
          "•",
          Tab.headIndent(14),
          "Pesticides\n",
          Tab.headIndent(14),
          "•",
          Tab.headIndent(14),
          "Pictures or images that contain frontal nudity\n",
          Tab.headIndent(14),
          "•",
          Tab.headIndent(14),
          "Police and Other Security Forces Badges and Uniforms\n",
          Tab.headIndent(14),
          "•",
          Tab.headIndent(14),
          "Prescription Drugs, medicines, supplements and Devices\n",
          Tab.headIndent(14),
          "•",
          Tab.headIndent(14),
          "Recalled items\n",
          Tab.headIndent(14),
          "•",
          Tab.headIndent(14),
          "Sexually suggestive clothing including but not limited to underwear, lingerie, bathing suits and erotic costumes\n",
          Tab.headIndent(14),
          "•",
          Tab.headIndent(14),
          "Stocks and Other Securities\n",
          Tab.headIndent(14),
          "•",
          Tab.headIndent(14),
          "Stolen Property\n",
          Tab.headIndent(14),
          "•",
          Tab.headIndent(14),
          "Tobacco Products (including vapes and e cigarettes)\n",
          Tab.headIndent(14),
          "•",
          Tab.headIndent(14),
          "Used Cosmetics\n",
          Tab.headIndent(14),
          "•",
          Tab.headIndent(14),
          "Weapons and related items (such as firearms, firearm parts and magazines, ammunition, BB and pellet guns, tear gas, stun guns, switchblade knives, and martial arts weapons).\n",
          Tab.headIndent(14),
          "•",
          Tab.headIndent(14),
          "Animal bi-products such as eggs, meat, cheese\n"
      ], baseStyle: privacyStyle)
    
    let string2 = NSAttributedString.composed(of: [
      "In addition, Cropswap reserves the right to remove any listings that we consider inappropriate or unfit for posting. Our policies are often based on applicable laws and regulations, although in some cases, we may make listing decisions based on input from our users and our own discretion, especially for dangerous or sensitive items.\n\n<bold>14. Rules of Use</bold>\n\n14.1. You agree to use the Website and the Application and its contents and services in accordance with the law, the morality, and the public order and in accordance with these Terms and Conditions. You are also obliged to make a proper use of the services and/or contents and to not use them to conduct illegal activities or constitute criminal offenses that violate the rights of third parties and/or violate the regulation on intellectual and industrial property, and any other rules of the applicable legal provisions.\n\n14.2. You are solely responsible for the interaction you establish with other Users of the Service and for all Content that you upload, post or transmit through the Website or Application. You also guarantee that you are not infringing any third party right by the content uploaded.\n\n14.3. In addition, you agree and acknowledge that Cropswap in no case will be held liable for the conduct of other Users.\n\n14.4. Cropswap prohibits the use of automated software and Posting Agents, directly or indirectly, without the express written permission of Cropswap. In addition, Posting Agents are not permitted to post Content on behalf of others, directly or indirectly, or otherwise access the Service to in order to post content on behalf of others, except with express written permission or license from Cropswap. As used herein, the term \"Posting Agent\" refers to a third-party agent, service, or intermediary that offers to post Content to the Service on behalf of others\n\n14.5. You agree not to transmit, enter, disseminate and make available to third parties any type of material and information (data, content, messages, drawings, sound files and image, photos, software, etc.) that are contrary to the law, morality, public order and these Terms and Conditions. You agree NOT to:\n\nI. Enter or disseminate content or propaganda which may be considered racist, xenophobic, pornographic or contrary to the human rights.\n\nII. Enter or disseminate in the network data programs (viruses and malicious software) that might cause damage to the computer systems of the access provider, its suppliers or third party users of the Internet.\n\nIII. Disseminate, transmit or make available to third parties any information, element or content that violates the fundamental rights and civil liberties recognized in international treaties.\n\nIV. Disseminate, transmit or make available to third parties any information, element or content that constitutes unlawful or unfair advertising.\n\nV. Enter or disseminate any information and content false, inaccurate or ambiguous in a manner which is misleading in the recipients of the information.\n\nVI. Disseminate, transmit or make available to third parties any information, element or content involving a violation of the intellectual and industrial property rights, patents, trademarks or copyright that correspond to Cropswap or to third parties.\n\nVII. Crawl, scrape, collect, store or access the database of Cropswap or collect all or part of the database of ads and users of Cropswap.\n\n14.6. You agree to hold Cropswap harmless of any possible claim, fine, penalty or punishment that can come to bear as a result from your breach of any of the rules stated in this document, reserving Cropswap the right to request compensation for damages.\n\n14.7. Cropswap develops maximum diligence in the control of the data and other content to be displayed in the Website and in the Application. If in spite of this you identify an error or incompleteness, we kindly ask you to notify us at the email address info@cropswapapp.com. Cropswap will reply as soon as possible.\n\n<bold>15. Notice and take down</bold>\n\nIf you believe your copyright-protected work was posted on Cropswap without authorization, you may submit a copyright infringement notification. These requests should only be submitted by the copyright owner or an agent authorized to act on the owner’s behalf. The fastest and easiest way to notify Cropswap of alleged copyright infringement is via our email : info@cropswapapp.com\n\n<bold>DMCA Notice</bold>\n\nYou may submit a notification pursuant to the Digital Millennium Copyright Act (DMCA) by providing our Copyright Agent with the following information in writing (see 17 U.S.C 512(c)(3) for further details):\n\n",
          "•",
          Tab.headIndent(14),
          "An electronic or physical signature of the person authorized to act on behalf of the owner of the copyright’s interests\n",
          "•",
          Tab.headIndent(14),
          "A description of the copyrighted work that you claim has been infringed, including the URL (i.e., web page address or item number) of the location where the copyrighted work exists or a copy of the copyrighted work\n",
          "•",
          Tab.headIndent(14),
          "Identification of the URL or other specific location on the Service where the material that you claim is infringing is located\n",
          "•",
          Tab.headIndent(14),
          "Your address, telephone number, and email address\n",
          "•",
          Tab.headIndent(14),
          "A statement that you have a good faith belief that the disputed use is not authorized by the copyright owner, its agent, or the law\n",
          "•",
          Tab.headIndent(14),
          "A statement by you, made under penalty of perjury, that the above information in your notice is accurate and that you are the copyright owner or authorized to act on the copyright owner’s behalf.\n\n",
          "<bold>16. Nullity and inefficiency of the clauses</bold>\n\nIf any clause included in the present Terms is declared total or partially void or inefficient, it will only affect that provision or the part of the same which is considered to be void or ineffective, surviving the present Terms and Conditions in everything else, considering such a provision wholly or partly not included.\n\n<bold>17. Applicable Law and Jurisdiction</bold>\n\nThese Terms and Conditions shall be governed by and construed in accordance with the legislation of the United States of America. You and Cropswap agree to submit any dispute that might arise in the delivery of the products or services subject to these Terms and Conditions, to the Courts of New York, United States of America or to the applicable jurisdiction in case of contracting with consumers."
      ], baseStyle: privacyStyle)
    
    let combination = NSMutableAttributedString()
    combination.append(string1)
    combination.append(string2)
    
    textView.attributedText = combination
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    acceptButton.makeMeBordered(borderWidth: 1, cornerRadius: 3)
    
    upperView.layer.shadowColor = UIColor.black.cgColor
    upperView.layer.shadowOffset = CGSize(width: 0, height: 0)
    upperView.layer.shadowRadius = 15
    upperView.layer.shadowOpacity = 0.6
    
    acceptView.layer.shadowOffset = CGSize(width: 0, height: 0);
    acceptView.layer.shadowRadius = 2;
    acceptView.layer.shadowColor = UIColor.black.cgColor
    acceptView.layer.shadowOpacity = 0.3;
  }
  
  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    textView.isScrollEnabled = true
  }
  
  @IBAction func acceptButtonTouched() {
    if comesFromSettings {
      dismiss(animated: true)
    } else {
      performSegue(withIdentifier: Storyboard.TermsToPrivacy, sender: nil)
    }
  }
  
  
}
