//
//  CDPopoverMenu.swift
//  弹出菜单
//
//  Created by CD826 on 16/8/10.
//  Copyright © 2016年 cd826. All rights reserved.
//

import UIKit

public enum CDPopoverMenuOption {
  case ArrowSize(CGSize)
  case AnimationIn(NSTimeInterval)
  case AnimationOut(NSTimeInterval)
  case CornerRadius(CGFloat)
  case SideEdge(CGFloat)
  case BlackOverlayColor(UIColor)
  case OverlayBlur(UIBlurEffectStyle)
  case Type(CDPopoverMenuType)
  case Color(UIColor)
}

@objc public enum CDPopoverMenuType: Int {
  case Up
  case Down
}

public class CDPopoverMenu: UIView {
  weak var delegate: CDPopoverMenuDelegate?
  weak var datasource: CDPopoverMenuDataSource?
  
  // custom property
  public var arrowSize: CGSize = CGSize(width: 16.0, height: 10.0)
  public var animationIn: NSTimeInterval = 0.6
  public var animationOut: NSTimeInterval = 0.3
  public var cornerRadius: CGFloat = 6.0
  public var sideEdge: CGFloat = 10.0
  public var popoverType: CDPopoverMenuType = .Down
  public var blackOverlayColor: UIColor = UIColor(white: 0.0, alpha: 0.0)
  public var overlayBlur: UIBlurEffect?
  public var popoverColor: UIColor = UIColor(red: 20.0 / 255.0, green: 23.0 / 255.0, blue: 28.0 / 255.0, alpha: 0.8)
  
  private var blackOverlay: UIControl = UIControl()
  private var containerView: UIView!
  private var contentView: UIView!
  private var contentViewFrame: CGRect!
  private var arrowShowPoint: CGPoint!
  
  public init() {
    super.init(frame: CGRect.zero)
    self.backgroundColor = UIColor.clearColor()
  }
  
  public init(options: [CDPopoverMenuOption]?) {
    super.init(frame: CGRect.zero)
    self.backgroundColor = UIColor.clearColor()
    self.setOptions(options)
  }
  
  private func setOptions(options: [CDPopoverMenuOption]?){
    if let options = options {
      for option in options {
        switch option {
        case let .ArrowSize(value):
          self.arrowSize = value
        case let .AnimationIn(value):
          self.animationIn = value
        case let .AnimationOut(value):
          self.animationOut = value
        case let .CornerRadius(value):
          self.cornerRadius = value
        case let .SideEdge(value):
          self.sideEdge = value
        case let .BlackOverlayColor(value):
          self.blackOverlayColor = value
        case let .OverlayBlur(style):
          self.overlayBlur = UIBlurEffect(style: style)
        case let .Type(value):
          self.popoverType = value
        case let .Color(value):
          self.popoverColor = value
        }
      }
    }
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func create() {
    var frame = self.contentView.frame
    frame.origin.x = self.arrowShowPoint.x - frame.size.width * 0.5
    
    var sideEdge: CGFloat = 0.0
    if frame.size.width < self.containerView.frame.size.width {
      sideEdge = self.sideEdge
    }
    
    let outerSideEdge = CGRectGetMaxX(frame) - self.containerView.bounds.size.width
    if outerSideEdge > 0 {
      frame.origin.x -= (outerSideEdge + sideEdge)
    } else {
      if CGRectGetMinX(frame) < 0 {
        frame.origin.x += abs(CGRectGetMinX(frame)) + sideEdge
      }
    }
    
    if let menuDataSource = self.datasource {
      frame.size.height = CGFloat(44 * menuDataSource.numberOfMenuItemsInPopoverMenu(self))
    } else {
      frame.size.height = self.contentView.frame.size.height
    }
    self.frame = frame
    
    let arrowPoint = self.containerView.convertPoint(self.arrowShowPoint, toView: self)
    let anchorPoint: CGPoint
    switch self.popoverType {
    case .Up:
      frame.origin.y = self.arrowShowPoint.y - frame.height - self.arrowSize.height
      anchorPoint = CGPoint(x: arrowPoint.x / frame.size.width, y: 1)
    case .Down:
      frame.origin.y = self.arrowShowPoint.y
      anchorPoint = CGPoint(x: arrowPoint.x / frame.size.width, y: 0)
    }
    
    let lastAnchor = self.layer.anchorPoint
    self.layer.anchorPoint = anchorPoint
    let x = self.layer.position.x + (anchorPoint.x - lastAnchor.x) * self.layer.bounds.size.width
    let y = self.layer.position.y + (anchorPoint.y - lastAnchor.y) * self.layer.bounds.size.height
    self.layer.position = CGPoint(x: x, y: y)
    
    frame.size.height += self.arrowSize.height
    self.frame = frame
  }
  
  public func show(contentView: UIView, fromView: UIView) {
    self.show(contentView, fromView: fromView, inView: UIApplication.sharedApplication().keyWindow!)
  }
  
  public func show(contentView: UIView, fromView: UIView, inView: UIView) {
    let point: CGPoint
    switch self.popoverType {
    case .Up:
      point = inView.convertPoint(CGPoint(x: fromView.frame.origin.x + (fromView.frame.size.width / 2), y: fromView.frame.origin.y), fromView: fromView.superview)
    case .Down:
      point = inView.convertPoint(CGPoint(x: fromView.frame.origin.x + (fromView.frame.size.width / 2), y: fromView.frame.origin.y + fromView.frame.size.height), fromView: fromView.superview)
    }
    self.show(contentView, point: point, inView: inView)
  }
  
  public func show(contentView: UIView, point: CGPoint) {
    self.show(contentView, point: point, inView: UIApplication.sharedApplication().keyWindow!)
  }
  
  public func show(contentView: UIView, point: CGPoint, inView: UIView) {
    self.blackOverlay.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    self.blackOverlay.frame = inView.bounds
    
    if let overlayBlur = self.overlayBlur {
      let effectView = UIVisualEffectView(effect: overlayBlur)
      effectView.frame = self.blackOverlay.bounds
      effectView.userInteractionEnabled = false
      self.blackOverlay.addSubview(effectView)
    } else {
      self.blackOverlay.backgroundColor = self.blackOverlayColor
      self.blackOverlay.alpha = 0
    }
    
    inView.addSubview(self.blackOverlay)
    self.blackOverlay.addTarget(self, action: #selector(CDPopoverMenu.dismiss), forControlEvents: .TouchUpInside)
    
    self.containerView = inView
    self.contentView = contentView
    self.contentView.backgroundColor = UIColor.clearColor()
    self.contentView.layer.cornerRadius = self.cornerRadius
    self.contentView.layer.masksToBounds = true
    self.arrowShowPoint = point
    self.show()
  }
  
  private func show() {
    self.setNeedsDisplay()
    switch self.popoverType {
    case .Up:
      self.contentView.frame.origin.y = 0.0
    case .Down:
      self.contentView.frame.origin.y = self.arrowSize.height
    }
    self.addSubview(self.contentView)
    self.containerView.addSubview(self)
    
    self.create()
    
    // 添加菜单
    if let menuDataSource = self.datasource {
      let menuItemsCount = menuDataSource.numberOfMenuItemsInPopoverMenu(self)
      if menuItemsCount > 0 {
        for i in 0..<menuItemsCount {
          self.createMenuItem(i, menuItemCount: menuItemsCount)
        }
      }
    }
    
    self.transform = CGAffineTransformMakeScale(0.0, 0.0)
    UIView.animateWithDuration(self.animationIn, delay: 0,
                               usingSpringWithDamping: 0.7,
                               initialSpringVelocity: 3,
                               options: .CurveEaseInOut,
                               animations: {
                                self.transform = CGAffineTransformIdentity
    }){ _ in
      // did do anything
    }
    UIView.animateWithDuration(self.animationIn / 3,
                               delay: 0,
                               options: .CurveLinear,
                               animations: { _ in
                                self.blackOverlay.alpha = 1
      }, completion: { _ in
    })
  }
  
  private func createMenuItem(itemIndex: Int, menuItemCount: Int) {
    if let menuDataSource = self.datasource {
      let menuItem: CDPopoverMenuItem = menuDataSource.popoverMenu(self, menuItemForItemIndex: itemIndex)
      let menuView: UIView = UIView()
      menuView.frame = CGRect(x: 0, y: self.arrowSize.height + CGFloat(44.0 * CGFloat(itemIndex)), width: self.frame.size.width, height: 44)
      
      let menuIcon: UIImageView = UIImageView()
      menuIcon.contentMode = UIViewContentMode.ScaleAspectFill
      menuIcon.image = UIImage(named: menuItem.icon!)
      menuIcon.frame = CGRect(x: 8, y: 13, width: 18, height: 18)
      menuView.addSubview(menuIcon)
      
      let menuLabel: UILabel = UILabel()
      menuLabel.text = menuItem.title!
      menuLabel.textColor = UIColor(red: 200.0 / 255.0, green: 200.0 / 255.0, blue: 200.0 / 255.0, alpha: 1.0)
      menuLabel.font = UIFont.systemFontOfSize(16.0)
      // menuLabel.backgroundColor = UIColor.whiteColor()
      menuLabel.frame = CGRect(x: 34, y: 0, width: menuView.frame.size.width - 5, height: menuView.frame.size.height)
      menuView.addSubview(menuLabel)
      
      // 判断是否需要显示badge
      if menuItem.badge! {
        let badgeView = UIView()
        badgeView.backgroundColor = UIColor(red: 0xfb/255.0, green: 0x3e/255.0, blue: 0x23/255.0, alpha: 1.0)
        badgeView.frame = CGRect(x: menuView.frame.size.width - 16.0 - 8.0, y: 18.0, width: 8, height: 8)
        badgeView.layer.cornerRadius = 4.0
        badgeView.clipsToBounds = true
        menuView.addSubview(badgeView)
      }
      
      if menuItemCount != itemIndex + 1 {
        let bottomBorderLayer = CALayer()
        bottomBorderLayer.backgroundColor = UIColor(red: 200.0 / 255.0, green: 200.0 / 255.0, blue: 200.0 / 255.0, alpha: 1.0).CGColor
        bottomBorderLayer.frame = CGRect(x: 0, y: menuView.frame.size.height - 0.5, width: menuView.frame.size.width, height: 0.5)
        menuView.layer.addSublayer(bottomBorderLayer)
      }
      
      // 添加一个点击掩层
      let button = UIButton(frame: CGRect(x: 0, y: 0, width: menuView.frame.size.width, height: menuView.frame.size.height))
      button.tag = itemIndex
      button.backgroundColor = UIColor.clearColor()
      button.addTarget(self, action: #selector(CDPopoverMenu.tappedMenuItem(_:)), forControlEvents: .TouchUpInside)
      menuView.addSubview(button)
      
      self.addSubview(menuView)
    }
  }
  
  @objc private func tappedMenuItem(button: UIButton) {
    if let menuDelegate = self.delegate {
      menuDelegate.popoverMenu(self, didSelectAtIndex: button.tag)
    }
    self.dismiss()
  }
  
  public func dismiss() {
    if self.superview != nil {
      UIView.animateWithDuration(self.animationOut, delay: 0,
                                 options: .CurveEaseInOut,
                                 animations: {
                                  self.transform = CGAffineTransformMakeScale(0.0001, 0.0001)
                                  self.blackOverlay.alpha = 0
      }){ _ in
        self.contentView.removeFromSuperview()
        self.blackOverlay.removeFromSuperview()
        self.removeFromSuperview()
      }
    }
  }
  
  override public func drawRect(rect: CGRect) {
    super.drawRect(rect)
    
    let arrow = UIBezierPath()
    let color: UIColor = self.popoverColor
    let arrowPoint = self.containerView.convertPoint(self.arrowShowPoint, toView: self)
    switch self.popoverType {
    case .Up:
      arrow.moveToPoint(CGPoint(x: arrowPoint.x, y: self.bounds.height))
      arrow.addLineToPoint(
        CGPoint(
          x: arrowPoint.x - self.arrowSize.width * 0.5,
          y: isCornerLeftArrow() ? self.arrowSize.height : self.bounds.height - self.arrowSize.height
        )
      )
      
      arrow.addLineToPoint(CGPoint(x: self.cornerRadius, y: self.bounds.height - self.arrowSize.height))
      arrow.addArcWithCenter(
        CGPoint(
          x: self.cornerRadius,
          y: self.bounds.height - self.arrowSize.height - self.cornerRadius
        ),
        radius: self.cornerRadius,
        startAngle: self.radians(90),
        endAngle: self.radians(180),
        clockwise: true)
      
      arrow.addLineToPoint(CGPoint(x: 0, y: self.cornerRadius))
      arrow.addArcWithCenter(
        CGPoint(
          x: self.cornerRadius,
          y: self.cornerRadius
        ),
        radius: self.cornerRadius,
        startAngle: self.radians(180),
        endAngle: self.radians(270),
        clockwise: true)
      
      arrow.addLineToPoint(CGPoint(x: self.bounds.width - self.cornerRadius, y: 0))
      arrow.addArcWithCenter(
        CGPoint(
          x: self.bounds.width - self.cornerRadius,
          y: self.cornerRadius
        ),
        radius: self.cornerRadius,
        startAngle: self.radians(270),
        endAngle: self.radians(0),
        clockwise: true)
      
      arrow.addLineToPoint(CGPoint(x: self.bounds.width, y: self.bounds.height - self.arrowSize.height - self.cornerRadius))
      arrow.addArcWithCenter(
        CGPoint(
          x: self.bounds.width - self.cornerRadius,
          y: self.bounds.height - self.arrowSize.height - self.cornerRadius
        ),
        radius: self.cornerRadius,
        startAngle: self.radians(0),
        endAngle: self.radians(90),
        clockwise: true)
      
      arrow.addLineToPoint(CGPoint(x: arrowPoint.x + self.arrowSize.width * 0.5,
        y: isCornerRightArrow() ? self.arrowSize.height : self.bounds.height - self.arrowSize.height))
      
    case .Down:
      arrow.moveToPoint(CGPoint(x: arrowPoint.x, y: 0))
      arrow.addLineToPoint(
        CGPoint(
          x: arrowPoint.x + self.arrowSize.width * 0.5,
          y: isCornerRightArrow() ? self.arrowSize.height + self.bounds.height : self.arrowSize.height
        ))
      
      arrow.addLineToPoint(CGPoint(x: self.bounds.width - self.cornerRadius, y: self.arrowSize.height))
      arrow.addArcWithCenter(
        CGPoint(
          x: self.bounds.width - self.cornerRadius,
          y: self.arrowSize.height + self.cornerRadius
        ),
        radius: self.cornerRadius,
        startAngle: self.radians(270.0),
        endAngle: self.radians(0),
        clockwise: true)
      
      arrow.addLineToPoint(CGPoint(x: self.bounds.width, y: self.bounds.height - self.cornerRadius))
      arrow.addArcWithCenter(
        CGPoint(
          x: self.bounds.width - self.cornerRadius,
          y: self.bounds.height - self.cornerRadius
        ),
        radius: self.cornerRadius,
        startAngle: self.radians(0),
        endAngle: self.radians(90),
        clockwise: true)
      
      arrow.addLineToPoint(CGPoint(x: 0, y: self.bounds.height))
      arrow.addArcWithCenter(
        CGPoint(
          x: self.cornerRadius,
          y: self.bounds.height - self.cornerRadius
        ),
        radius: self.cornerRadius,
        startAngle: self.radians(90),
        endAngle: self.radians(180),
        clockwise: true)
      
      arrow.addLineToPoint(CGPoint(x: 0, y: self.arrowSize.height + self.cornerRadius))
      arrow.addArcWithCenter(
        CGPoint(x: self.cornerRadius,
          y: self.arrowSize.height + self.cornerRadius
        ),
        radius: self.cornerRadius,
        startAngle: self.radians(180),
        endAngle: self.radians(270),
        clockwise: true)
      
      arrow.addLineToPoint(CGPoint(x: arrowPoint.x - self.arrowSize.width * 0.5,
        y: isCornerLeftArrow() ? self.arrowSize.height + self.bounds.height : self.arrowSize.height))
    }
    
    color.setFill()
    arrow.fill()
  }
  
  private func isCornerLeftArrow() -> Bool {
    return self.arrowShowPoint.x == self.frame.origin.x
  }
  
  private func isCornerRightArrow() -> Bool {
    return self.arrowShowPoint.x == self.frame.origin.x + self.bounds.width
  }
  
  private func radians(degrees: CGFloat) -> CGFloat {
    return (CGFloat(M_PI) * degrees / 180)
  }
}

// MARK: - 菜单属性
class CDPopoverMenuItem {
  // 菜单标题
  var title: String?
  // 菜单图标
  var icon: String?
  // 是否在菜单尾部显示提示，比如有新消息
  var badge: Bool?
  
  // MARK: - init
  required init() {
    badge = false
  }
  
  required init(aTitle: String, aIcon: String) {
    title = aTitle
    icon = aIcon
    badge = false
  }
  
  required init(aTitle: String, aIcon: String, aBadge: Bool) {
    title = aTitle
    icon = aIcon
    badge = aBadge
  }
}

// MARK: - 弹出菜单事件代理
protocol CDPopoverMenuDelegate: class {
  func popoverMenu(popoverMenu: CDPopoverMenu, didSelectAtIndex menuIndex: Int)
}

// MARK: - 弹出菜单的菜单项数据源
protocol CDPopoverMenuDataSource: class {
  func numberOfMenuItemsInPopoverMenu(popoverMenu: CDPopoverMenu) -> Int
  
  func popoverMenu(popoverMenu: CDPopoverMenu, menuItemForItemIndex itemIndex: Int) -> CDPopoverMenuItem
}