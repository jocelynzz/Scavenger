//
//  Copyright © 2014 Yalantis
//  Licensed under the MIT license: http://opensource.org/licenses/MIT
//  Latest version can be found at http://github.com/yalantis/Side-Menu.iOS
//

import SideMenu

@objc protocol MenuViewControllerDelegate: class {
    func menu(menu: MenuViewController, didSelectItemAtIndex index: Int, atPoint point: CGPoint)
    func menuDidCancel(menu: MenuViewController)
}

class MenuViewController: UITableViewController {
    weak var delegate: MenuViewControllerDelegate?
    var selectedItem = 0

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

//        let indexPath = NSIndexPath(forRow: selectedItem, inSection: 0)
//        tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
    }
    
    func setDelegate(del: MenuViewControllerDelegate) {
        delegate = del;
    }
}

extension MenuViewController {
    @IBAction
    private func dismissMenu() {
        delegate?.menuDidCancel(self)
    }
}

extension MenuViewController: Menu {
    var menuItems: [UIView] {
        return [tableView.tableHeaderView!] + tableView.visibleCells() as [UIView]
    }
}

extension MenuViewController: UITableViewDelegate {
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
//        if (indexPath.row == 0) {
//            performSegueWithIdentifier("showMyNotes", sender:self);
//        } else if (indexPath.row == 1) {
//            performSegueWithIdentifier("showNotesOnMap", sender:self);
//        }
        return indexPath == tableView.indexPathForSelectedRow() ? nil : indexPath
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let rect = tableView.rectForRowAtIndexPath(indexPath)
        var point = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))
        point = tableView.convertPoint(point, toView: nil)
        delegate?.menu(self, didSelectItemAtIndex: indexPath.row, atPoint:point)
    }
}
