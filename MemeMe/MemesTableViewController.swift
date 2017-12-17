import UIKit

class MemesTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var memes = [Meme]()

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tabBarItem.title = ""
        tabBarItem.image = UIImage(named: "table")

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        memes = appDelegate.memes

        tableView.delegate = self
        tableView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        memes = appDelegate.memes

        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableViewCell = (tableView.dequeueReusableCell(withIdentifier: "table_cell")! as? MemeTableViewCell)!
        tableViewCell.memeLabel.text = memes[indexPath.row].topText + " " + memes[indexPath.row].bottomText
        tableViewCell.memeImageView.image = memes[indexPath.row].modifiedImage
        return tableViewCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let memeDetailsViewController = (self.storyboard!.instantiateViewController(withIdentifier: "MemeDetailsViewController") as? MemeDetailsViewController)!
        memeDetailsViewController.image = memes[indexPath.row].modifiedImage
        self.navigationController?.pushViewController(memeDetailsViewController, animated: true)
    }
}
