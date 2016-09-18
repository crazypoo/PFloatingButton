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

    func initInKeyWindowWithFrame(frame: CGRect) {
        self.frame = frame
        self.perform(#selector(addButtonToKeyWindow), with: nil, afterDelay: 0)
        defaultSetting()
    }

    required internal init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func defaultSetting() {
        draggable = true
        autoDocking = true
        _singleTapBeenCanceled = false

        _longPressGestureRecognizer.addTarget(self, action: #selector(self.gestureRecognizerHandle(gestureRecognizer:)))
        _longPressGestureRecognizer.allowableMovement = 0
        self.addGestureRecognizer(_longPressGestureRecognizer)
    }

    func addButtonToKeyWindow()
    {
        UIApplication.shared.keyWindow?.addSubview(self)
    }

    func gestureRecognizerHandle(gestureRecognizer:UILongPressGestureRecognizer) {
        switch gestureRecognizer.state
        {
        case .began:
            if longPressBlock != nil {
                longPressBlock!(self)
            }
            break
        default: break

        }
    }

    func setTapBlocks(tapBlocks: @escaping (PFloatingButton) -> Void) {
        tapBlock = tapBlocks
        if tapBlock != nil
        {
            self.addTarget(self, action: #selector(buttonTouched), for: .touchUpInside)
        }

    }

    func buttonTouched()
    {
        if doubleTapBlock != nil {
            self.perform(#selector(executeButtonTouchedBlock), with: nil, afterDelay:0.36)
        }
        else
        {
            self.perform(#selector(executeButtonTouchedBlock), with: nil, afterDelay:0)
        }
    }

    func executeButtonTouchedBlock()
    {
        if !_singleTapBeenCanceled && !_isDragging && tapBlock != nil{
            tapBlock!(self)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        _isDragging = false
        super.touchesBegan(touches, with: event)
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
            _beginLocation = touch.location(in: self)
        }

    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if draggable {
            _isDragging = true
            let touch:UITouch = touches.first!
            let currentLocation:CGPoint = touch.location(in: self)
            let offsetX = currentLocation.x - _beginLocation.x
            let offsetY = currentLocation.y - _beginLocation.y
            self.center = CGPoint.init(x: self.center.x + offsetX, y: self.center.y + offsetY)
            let superviewFrame:CGRect = (self.superview?.frame)!
            let frame:CGRect = self.frame
            let leftLimitX:CGFloat = frame.size.width/2
            let rightLimitX:CGFloat = superviewFrame.size.width - leftLimitX
            let topLimitY:CGFloat = frame.size.height/2
            let bottomLimitY:CGFloat = superviewFrame.size.height - topLimitY

            if (self.center.x > rightLimitX)
            {
                self.center = CGPoint.init(x: rightLimitX, y: self.center.y)
            }
            else if (self.center.x <= leftLimitX) {
                self.center = CGPoint.init(x: leftLimitX, y: self.center.y)
            }
            if (self.center.y > bottomLimitY)
            {
                self.center = CGPoint.init(x: self.center.x, y: bottomLimitY)
            }
            else if (self.center.y <= topLimitY)
            {
                self.center = CGPoint.init(x: self.center.x, y: topLimitY)
            }
            if draggingBlock != nil {
                draggingBlock!(self)
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
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
                UIView.animate(withDuration: 0.2, animations: {
                    self.center = CGPoint.init(x: superviewFrame.size.width - frame.size.width / 2, y: self.center.y)
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
                UIView.animate(withDuration: 0.2, animations: {
                    self.center = CGPoint.init(x: frame.size.width / 2, y: self.center.y)
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

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        _isDragging = false
        super.touchesCancelled(touches, with: event)
    }

    func isDragging()->Bool
    {
        return _isDragging
    }

    func version()->NSString
    {
        return "0.1"
    }

    func removeAllFromKeyWindow()
    {
        for view:UIView in (UIApplication.shared.keyWindow?.subviews)!
        {
            if view.isKind(of: type(of: PFloatingButton())) {
                view.removeFromSuperview()
            }
        }
    }

    func removeAllFromView(superView:AnyObject)
    {
        for view:UIView in superView.subviews {
            if view.isKind(of: type(of: PFloatingButton()))
            {
                view.removeFromSuperview()
            }
        }
    }
}
