//
//  PButtonBlock.swift
//  SwiftBlockTest
//
//  Created by 邓杰豪 on 2016/9/1.
//  Copyright © 2016年 邓杰豪. All rights reserved.
//

import UIKit

typealias _longPressBlock = (PFloatingButton) -> Void
typealias _tapBlock = (PFloatingButton) -> Void
typealias _doubleTapBlock = (PFloatingButton) -> Void
typealias _draggingBlock = (PFloatingButton) -> Void
typealias _dragDoneBlock = (PFloatingButton) -> Void
typealias _autoDockingBlock = (PFloatingButton) -> Void
typealias _autoDockingDoneBlock = (PFloatingButton) -> Void

class PFloatingButton: UIButton {


    let _longPressGestureRecognizer = UILongPressGestureRecognizer()
    var _isDragging = Bool()
    var _singleTapBeenCanceled = Bool()
    var _beginLocation = CGPoint()

    var draggable = Bool()
    var autoDocking = Bool()

    var longPressBlock : _longPressBlock!
    var tapBlock : _tapBlock!
    var doubleTapBlock : _doubleTapBlock!
    var draggingBlock : _draggingBlock!
    var dragDoneBlock : _dragDoneBlock!
    var autoDockingBlock : _autoDockingBlock!
    var autoDockingDoneBlock : _autoDockingDoneBlock!


    override init(frame: CGRect) {
       super.init(frame: frame)
        defaultSetting()
    }

    func initInView(view: AnyObject, WithFrame frame: CGRect) -> AnyObject {
        self.frame = frame
        view.addSubview(self)
        self.defaultSetting()
        return self
    }

    func initInKeyWindowWithFrame(frame: CGRect) -> AnyObject {
        self.frame = frame
        self.performSelector(#selector(addButtonToKeyWindow), withObject: nil, afterDelay: 0)
        defaultSetting()
        return self
    }

    required internal init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func defaultSetting() {
        draggable = true
        autoDocking = true
        _singleTapBeenCanceled = false

        _longPressGestureRecognizer.addTarget(self, action: #selector(PFloatingButton.gestureRecognizerHandle(_:)))
        _longPressGestureRecognizer.allowableMovement = 0
        self.addGestureRecognizer(_longPressGestureRecognizer)
    }

    func addButtonToKeyWindow()
    {
        UIApplication.sharedApplication().keyWindow?.addSubview(self)
    }

    func gestureRecognizerHandle(gestureRecognizer:UILongPressGestureRecognizer) {
        switch gestureRecognizer.state
        {
        case .Began:
            if longPressBlock != nil {
                longPressBlock!(self)
            }
            break
        default: break

        }
    }

    func setTapBlocks(tapBlocks: (PFloatingButton) -> Void) {
        tapBlock = tapBlocks
        if tapBlock != nil
        {
            self.addTarget(self, action: #selector(buttonTouched), forControlEvents: .TouchUpInside)
        }

    }

    func buttonTouched()
    {
        if doubleTapBlock != nil {
            self.performSelector(#selector(executeButtonTouchedBlock), withObject: nil, afterDelay:0.36)
        }
        else
        {
            self.performSelector(#selector(executeButtonTouchedBlock), withObject: nil, afterDelay:0)
        }
    }

    func executeButtonTouchedBlock()
    {
        if !_singleTapBeenCanceled && !_isDragging && tapBlock != nil{
            tapBlock!(self)
        }
    }

    internal override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        _isDragging = false
        super.touchesBegan(touches, withEvent: event)
        let touch:UITouch = touches.first!
        if touch.tapCount == 2
        {
            if doubleTapBlock != nil {
                _singleTapBeenCanceled = true
                doubleTapBlock!(self)
            }
            else
            {
                _singleTapBeenCanceled = false
            }
            _beginLocation = touch.locationInView(self)
        }
    }

    internal override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if draggable {
            _isDragging = true
            let touch:UITouch = touches.first!
            let currentLocation:CGPoint = touch.locationInView(self)
            let offsetX = currentLocation.x - _beginLocation.x
            let offsetY = currentLocation.y - _beginLocation.y
            self.center = CGPointMake(self.center.x + offsetX, self.center.y + offsetY)
            let superviewFrame:CGRect = (self.superview?.frame)!
            let frame:CGRect = self.frame
            let leftLimitX:CGFloat = frame.size.width/2
            let rightLimitX:CGFloat = superviewFrame.size.width - leftLimitX
            let topLimitY:CGFloat = frame.size.height/2
            let bottomLimitY:CGFloat = superviewFrame.size.height - topLimitY

            if (self.center.x > rightLimitX)
            {
                self.center = CGPointMake(rightLimitX, self.center.y)
            }
            else if (self.center.x <= leftLimitX) {
                self.center = CGPointMake(leftLimitX, self.center.y)
            }
            if (self.center.y > bottomLimitY)
            {
                self.center = CGPointMake(self.center.x, bottomLimitY)
            }
            else if (self.center.y <= topLimitY)
            {
                self.center = CGPointMake(self.center.x, topLimitY)
            }
            if draggingBlock != nil {
                draggingBlock!(self)
            }
        }
    }

    internal override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        if (_isDragging && dragDoneBlock != nil) {
            dragDoneBlock!(self);
            _singleTapBeenCanceled = true;
        }
        if (_isDragging && autoDocking)
        {
            let superviewFrame:CGRect = (self.superview?.frame)!
            let frame = self.frame
            let middleX = superviewFrame.size.width/2

            if (self.center.x >= middleX) {
                UIView.animateWithDuration(0.2, animations: { 
                    self.center = CGPointMake(superviewFrame.size.width - frame.size.width / 2, self.center.y)
                    if self.autoDockingBlock != nil {
                        self.autoDockingBlock!(self)
                    }
                    }, completion: { (finish) in
                        if self.autoDockingDoneBlock != nil {
                            self.autoDockingDoneBlock!(self);
                        }
                })
            }
            else
            {
                UIView.animateWithDuration(0.2, animations: {
                    self.center = CGPointMake(frame.size.width / 2, self.center.y)
                    if self.autoDockingBlock != nil {
                        self.autoDockingBlock!(self)
                    }
                    }, completion: { (finish) in
                        if self.autoDockingDoneBlock != nil {
                            self.autoDockingDoneBlock!(self);
                        }
                })
            }
        }
        _isDragging = false
    }

    internal override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        _isDragging = false
        super.touchesCancelled(touches, withEvent: event)
    }

    func isDragging()->Bool
    {
        return _isDragging
    }

    func version()->NSString
    {
        return "0.2"
    }

    func removeAllFromKeyWindow()
    {
        for view:AnyObject in (UIApplication.sharedApplication().keyWindow?.subviews)! {
            if view.isKindOfClass(PFloatingButton) {
                view.removeFromSuperview()
            }
        }
    }

    func removeAllFromView(superView:AnyObject)
    {
        for view:AnyObject in superView.subviews {
            if view.isKindOfClass(PFloatingButton) {
                view.removeFromSuperview()
            }
        }
    }
}
