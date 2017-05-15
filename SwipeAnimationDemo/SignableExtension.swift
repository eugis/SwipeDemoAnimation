//
//  SignableExtension.swift
//  SwipeAnimationDemo
//
//  Created by Eugenia Sakuda on 5/15/17.
//  Copyright © 2017 Eugenia Sakuda. All rights reserved.
//

import Foundation
import UIKit

protocol Signable: Comparable {
    init()
}

extension Signable {
    func sign() -> Float {
        return (self < Self() ? -1 : 1)
    }
}

/* extend signed integer types to Signable */
extension Int: Signable { }    // already have < and init() functions, OK
extension Int8 : Signable { }  // ...
extension Int16 : Signable { }
extension Int32 : Signable { }
extension Int64 : Signable { }

/* extend floating point types to Signable */
extension Double : Signable { }
extension Float : Signable { }
extension CGFloat: Signable { }
