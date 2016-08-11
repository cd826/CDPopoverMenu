# CDPopoverMenu(Swift)
本控件是一个弹出式菜单控件。  

![image](https://github.com/cd826/CDPopoverMenu/blob/master/demo.gif?raw=true)

## 使用方法
```swift
class ViewController: UIViewController {
  private var popoverMenuItems = [CDPopoverMenuItem]()
  private var popoverMenu: CDPopoverMenu!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // 加载菜单项
    initPopoverMenu()
    
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func tappedMoreAction(sender: AnyObject) {
    let popoverMenu = CDPopoverMenu()
    popoverMenu.delegate = self
    popoverMenu.datasource = self
    let aView = UIView(frame: CGRect(x: 0, y: 0, width: 160, height: 180))
    let startPoint = CGPoint(x: self.view.frame.width - 30, y: 55)
    
    popoverMenu.show(aView, point: startPoint)
  }
  
  private func initPopoverMenu() {
    self.popoverMenuItems.append(CDPopoverMenuItem(aTitle: "消息", aIcon: "message", aBadge: true))
    self.popoverMenuItems.append(CDPopoverMenuItem(aTitle: "首页", aIcon: "home"))
    self.popoverMenuItems.append(CDPopoverMenuItem(aTitle: "分享", aIcon: "share"))
    self.popoverMenuItems.append(CDPopoverMenuItem(aTitle: "帮助", aIcon: "help"))
  }
}

// MARK: - CDPopoverMenu 代理和数据源
extension ViewController: CDPopoverMenuDelegate, CDPopoverMenuDataSource {
  func numberOfMenuItemsInPopoverMenu(popoverMenu: CDPopoverMenu) -> Int {
    return popoverMenuItems.count
  }
  
  func popoverMenu(popoverMenu: CDPopoverMenu, menuItemForItemIndex itemIndex: Int) -> CDPopoverMenuItem {
    return popoverMenuItems[itemIndex]
  }
  
  func popoverMenu(popoverMenu: CDPopoverMenu, didSelectAtIndex menuIndex: Int) {
    let alertController = UIAlertController(title: "系统提示",
                                            message: "你选择了 \(popoverMenuItems[menuIndex].title!) 菜单", preferredStyle: UIAlertControllerStyle.Alert)
    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
    alertController.addAction(okAction)
    self.presentViewController(alertController, animated: true, completion: nil)
  }
}
```

