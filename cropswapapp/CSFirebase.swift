//
//  CSFirebase.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 5/23/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import FirebaseDatabase

class CSFirebase {
  static var refDatabase: FIRDatabaseReference = {
    return FIRDatabase.database().reference()
  }()
}
