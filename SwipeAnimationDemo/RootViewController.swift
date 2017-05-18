//
//  RootViewController.swift
//  SwipeAnimationDemo
//
//  Created by Eugenia Sakuda on 5/11/17.
//  Copyright © 2017 Eugenia Sakuda. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {

    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    
    @IBOutlet weak var rightArrowView: UIView!
    @IBOutlet weak var leftArrowView: UIView!
    
    @IBOutlet weak var rightViewAlertLabel: UILabel!
    // TODO: is missing to add leftLabel
    
    @IBOutlet weak var animateRoundedButton: UIButton!
    @IBOutlet weak var restartButton: UIButton!
    fileprivate var _pageViewController: UIPageViewController?
    fileprivate var _monthsViewModel: MonthsViewModel? = .none
    
    fileprivate var _originRightArrowViewPosition: CGRect!
    fileprivate var _originLeftArrowViewPosition: CGRect!
    
    fileprivate var _viewBeingAnimated: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeViewModel()
        loadPageViewController()
        setArrowsViewStyle()
        initializeGestures()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _originRightArrowViewPosition = rightArrowView.frame
        _originLeftArrowViewPosition = leftArrowView.frame
        self.rightViewAlertLabel.alpha = 1;

    }
    func initializeViewModel() {
        _monthsViewModel = MonthsViewModel()
    }
    
    @IBAction func reset(_ sender: Any) {
        rightArrowView.layer.removeAllAnimations()
        rightArrowView.frame = _originRightArrowViewPosition
        rightArrowView.layer.cornerRadius = rightArrowView.frame.size.height / 2
        
        leftArrowView.layer.removeAllAnimations()
        leftArrowView.frame = _originLeftArrowViewPosition
        leftArrowView.layer.cornerRadius = leftArrowView.frame.size.height / 2
    }
    
    @IBAction func animateRadius(_ sender: Any) {
        rightArrowView.testAnimation()
        UIView.animate(withDuration: 6.0) {
            self.rightViewAlertLabel.alpha = 1;
            self.view.bringSubview(toFront: self.rightViewAlertLabel)
        }
    }
}

extension RootViewController {
    
    internal func loadPageViewController() {
        _pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: .none)
        _pageViewController!.delegate = self
        
        _monthsViewModel?.setCurrent(index: 0)
        let startingViewController: DataViewController = viewControllerAtIndex(0)!
        let viewControllers = [startingViewController]
        _pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: false, completion: .none)
        
        _pageViewController!.dataSource = self
        
        addChildViewController(_pageViewController!)
        view.addSubview(_pageViewController!.view)
        
        // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
        var pageViewRect = view.bounds
        if UIDevice.current.userInterfaceIdiom == .pad {
            pageViewRect = pageViewRect.insetBy(dx: 40.0, dy: 40.0)
        }
        _pageViewController!.view.frame = pageViewRect
        _pageViewController!.didMove(toParentViewController: self)
    }
    
    internal func setArrowsViewStyle() {
        rightArrowView.layer.cornerRadius = rightArrowView.frame.height / 2
        rightArrowView.layer.borderColor = UIColor.white.cgColor
        rightArrowView.layer.borderWidth = 2.0
        rightArrowView.isHidden = _monthsViewModel!.elementsCount == 0
        rightArrowView.layer.zPosition = 0.5
        
        
        leftArrowView.layer.cornerRadius = rightArrowView.frame.height / 2
        leftArrowView.layer.borderColor = UIColor.white.cgColor
        leftArrowView.layer.borderWidth = 2.0
        leftArrowView.isHidden = true // This is considreing the initialization of pageViewController to be at 0
        leftArrowView.layer.zPosition = 0.5
        
        rightViewAlertLabel.text = _monthsViewModel?.alertMessage
        
        restartButton.layer.zPosition = 0.5
    }
    
    internal func initializeGestures() {
        panGestureRecognizer.addTarget(self, action: #selector(handleDragGesture(gesture:)))
        
        let rTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(gesture:)) )
        rightArrowView.addGestureRecognizer(rTapGestureRecognizer)
        
        let lTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(gesture:)) )
        leftArrowView.addGestureRecognizer(lTapGestureRecognizer)
    }
}

fileprivate extension RootViewController {
    
    func viewControllerAtIndex(_ index: UInt) -> DataViewController? {
        
        guard let month = _monthsViewModel?.element(at: index) else { return .none }
        
        // Create a new view controller and pass suitable data.
        
        let dataViewController = storyboard?.instantiateViewController(withIdentifier: "DataViewController") as! DataViewController
        dataViewController.dataObject = month
        return dataViewController
    }
    
    func indexOfViewController(_ viewController: DataViewController) -> UInt? {
        return _monthsViewModel?.index(of: viewController.dataObject)
    }
}

extension RootViewController {
    
    internal func handleDragGesture(gesture: UIPanGestureRecognizer) {
        guard canAnimate() else { return }
        switch gesture.state {
        case .began:
            _viewBeingAnimated = .none
        case .changed:
            // TODO: verify code style
            let xTranslation = gesture.translation(in: gesture.view).x
            let direction: Direction = xTranslation < 0 ? .right : .left
            if _viewBeingAnimated == .none {
                guard isValid(direction: direction) else { return }
                _viewBeingAnimated = xTranslation < 0 ? rightArrowView : leftArrowView
            }
            handleDragForArrow(with: xTranslation)
        case .ended:
            if (_originRightArrowViewPosition.size != rightArrowView.frame.size) {
                rightArrowView.restaureSize(upTo: _originRightArrowViewPosition, completionHandler: .none)
            }
//            if (_originLeftArrowViewPosition.size != leftArrowView.frame.size) {
//                leftArrowView.restaureSize(upTo: _originLeftArrowViewPosition, completionHandler: .none)
//            }
            _viewBeingAnimated = .none
        default: break
        }
    }
    
    internal func handleTapGesture(gesture: UITapGestureRecognizer) {
        let direction: Direction = gesture.view == rightArrowView ? .right : .left
        handleAnimation(with: direction)
    }
    
    internal func handleSwipeGesture(gesture: UISwipeGestureRecognizer) {
        let direction: Direction = gesture.direction == .right ? .right : .left
        handleAnimation(with: direction)
    }
    
    private func handleAnimation(with direction: Direction) {
        guard canAnimate() else { return }
        let viewToAnimate = direction == .right ? rightArrowView : leftArrowView
        let originViewFrame = direction == .right ? _originRightArrowViewPosition : _originLeftArrowViewPosition
        let complementaryFrame = direction == .right ? leftArrowView : rightArrowView
        complementaryFrame?.layer.zPosition = 0.5
        viewToAnimate!.animateBigger(from: originViewFrame,
                                     with: direction.oposite,
                                     firstHandler: { [unowned self] in self.animateAndUpdate(direction: direction) },
                                     completionHandler: { [unowned self] _ in self.complementaryAnimation(for: viewToAnimate!) })
    }
}

fileprivate extension RootViewController {
    
    fileprivate func handleDragForArrow(with xTranslation: CGFloat) {
        guard let viewBeingAnimated = _viewBeingAnimated else { return }
        let direction: Direction = viewBeingAnimated == rightArrowView ? .right : .left
        let frame = viewBeingAnimated == rightArrowView ? _originRightArrowViewPosition : _originLeftArrowViewPosition
        let complementaryView = viewBeingAnimated == rightArrowView ? rightArrowView : rightArrowView // TODO: update this
        _ = viewBeingAnimated.animateBigger(from: frame, with: direction, firstHandler: { [unowned self] in self.animateAndUpdate(direction: direction) })
//        _ = viewBeingAnimated.updateAnimation(with: xTranslation, to: frame!, with: complementaryView!, firstHandler: { [unowned self] _ in
//            self.animateAndUpdate(direction: direction)
//            complementaryView!.alpha = 1.0
//            self._viewBeingAnimated!.frame = self._originRightArrowViewPosition // TODO: this should using the origin frame, from the view being animated
//            self._viewBeingAnimated!.fadeInAnimation(toShow: true)
//        })
    }
    
    fileprivate func animateAndUpdate(direction: Direction) {
        guard let currentIndex = _monthsViewModel?.currentIndex else { return } // This should never happen
        let index = UInt(Int(currentIndex) + Int(direction.rawValue))
        let nextController = self.viewControllerAtIndex(index)!
        _monthsViewModel?.setCurrent(index: index)
        self._pageViewController?.setViewControllers([nextController], direction: .forward, animated: false, completion: nil)
        animateText(with: direction)
    }
    
    fileprivate func isValid(direction: Direction) -> Bool {
         guard let currentIndex = _monthsViewModel?.currentIndex else { return false } // This should never happen
        let index = UInt(Int(currentIndex) + Int(direction.rawValue))
        return _monthsViewModel!.isValid(index)
    }
    
    fileprivate func animateText(with direction: Direction) {
        if let view = direction == .left ? rightViewAlertLabel : rightViewAlertLabel { // TODO: this should be updated to use leftlabel too
            view.fadeInOutAnimation()
        }
    }
    
    fileprivate func canAnimate() -> Bool {
        guard rightArrowView.layer.animationKeys() == nil else { return false }
        guard leftArrowView.layer.animationKeys() == nil else { return false }
        return true
    }
    
    fileprivate func complementaryAnimation(for animatedView: UIView) {
        let complementaryView = animatedView == rightArrowView ? leftArrowView : rightArrowView
        let originFrame = animatedView == rightArrowView ? _originRightArrowViewPosition : _originLeftArrowViewPosition
        complementaryView!.isHidden = false
        animatedView.frame = originFrame!
        if _monthsViewModel?.currentIndex != 0 && _monthsViewModel?.currentIndex != _monthsViewModel?.elementsCount {
            animatedView.fadeInAnimation(toShow: true)
        }
    }
}

extension RootViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return .none
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return .none
    }
    
}
