import UIKit

@objc
protocol SidePanelViewControllerDelegate {
    func menuSelected(index: Int)
    func searchBarSearchButtonClicked(searchBar: UISearchBar!)
    func toggleGPS()
    func showFavorites()
    func contactUs()
}

class SidePanelViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
  var listItems1 = ["Ames", "Iowa City", "Cedar Falls", "Current Location"]
    var listItems2 = ["Show Favorites", "Turn Location On/Off", "Contact Us"]
    var sectionHeaders = ["Locations", "Settings"]
  @IBOutlet weak var slideOutSearchBar: UISearchBar!
  @IBOutlet weak var tableView: UITableView!

  var delegate: SidePanelViewControllerDelegate?


  override func viewDidLoad() {
    super.viewDidLoad()

    slideOutSearchBar.tintColor = UIColor.lightGrayColor()
    slideOutSearchBar.placeholder = "Search Bars"
    tableView.backgroundColor = UIColor.darkGrayColor()
    
    for subView in self.slideOutSearchBar.subviews
    {
        for secondLevelSubview in subView.subviews
        {
            if (secondLevelSubview.isKindOfClass(UITextField))
            {
                if let searchBarTextField:UITextField = secondLevelSubview as? UITextField
                {
                    searchBarTextField.textColor = UIColor.whiteColor()
                    break;
                }
                
            }
        }
    }
    
    tableView.reloadData()
  }

    func searchBarSearchButtonClicked(searchBar: UISearchBar!) {
        delegate?.searchBarSearchButtonClicked(searchBar)
    }

  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 2
  }

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if (section == 1){
        return listItems2.count
    }
    else{
        return listItems1.count
    }
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
    if (indexPath.section == 1){
        cell.textLabel?.text = listItems2[indexPath.row]
    }
    else{
        cell.textLabel?.text = listItems1[indexPath.row]
    }
    
    cell.textLabel?.textColor = UIColor.whiteColor()
    return cell
  }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionHeaders[section]
    }

  // Mark: Table View Delegate
  func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
    if (indexPath.section == 0){
        delegate?.menuSelected(indexPath.row)
    }
    else{
        switch(indexPath.row){
        case 0:
            // Show Favorites
            delegate?.showFavorites()
        case 1:
            // Toggle GPS
            delegate?.toggleGPS()
        case 2:
            // Contact Us
            delegate?.contactUs()
        default:
            print("wot m8")
        }
    }
  }
    
}