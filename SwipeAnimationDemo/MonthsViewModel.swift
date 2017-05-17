//
//  MonthsViewModel.swift
//  SwipeAnimationDemo
//
//  Created by Eugenia Sakuda on 5/11/17.
//  Copyright © 2017 Eugenia Sakuda. All rights reserved.
//

import UIKit

/*
 A controller object that manages a simple model -- a collection of month names.
 
 The controller serves as the data source for the page view controller; it therefore implements pageViewController:viewControllerBeforeViewController: and pageViewController:viewControllerAfterViewController:.
 It also implements a custom method, viewControllerAtIndex: which is useful in the implementation of the data source methods, and in the initial configuration of the application.
 
 There is no need to actually create view controllers for each page in advance -- indeed doing so incurs unnecessary overhead. Given the data model, these methods create, configure, and return a new view controller on demand.
 */


class MonthsViewModel: NSObject {

    fileprivate var _pageData: [String] = []

    override init() {
        super.init()
        // Create the data model.
        let dateFormatter = DateFormatter()
        _pageData = dateFormatter.monthSymbols
    }

    var elementsCount: UInt {
        return UInt(_pageData.count)
    }
    
    func element(at index: UInt) -> String? {
        guard index < elementsCount else { return .none }
        return _pageData[Int(index)]
    }

    func index(of element: String) -> UInt? {
        guard let index = _pageData.index(of: element) else { return .none }
        return UInt(index)
    }
    
    func isValid(_ index: UInt) -> Bool {
        return index < elementsCount
    }
    
    var alertMessage: String {
        return "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
    }
}

