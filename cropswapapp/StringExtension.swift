//
//  StringExtension.swift
//  cropswapapp
//
//  Created by Wilson Balderrama on 10/6/17.
//  Copyright © 2017 Cropswap. All rights reserved.
//

import Foundation

extension String {
  func matches(_ regex: String) -> Bool {
    return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
  }
}
