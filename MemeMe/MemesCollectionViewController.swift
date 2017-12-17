import UIKit

class MemesCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    var memes = [Meme]()
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        memes = appDelegate.memes

        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0

        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)

        collectionView.delegate = self
        collectionView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        memes = appDelegate.memes

        collectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var collectionViewCell = (collectionView.dequeueReusableCell(withReuseIdentifier: "collection_cell", for: indexPath) as? MemeCollectionViewCell)!

        collectionViewCell.imageView.image = memes[indexPath.row].modifiedImage

        return collectionViewCell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let memeDetailsViewController = (self.storyboard!.instantiateViewController(withIdentifier: "MemeDetailsViewController") as? MemeDetailsViewController)!
        memeDetailsViewController.image = memes[indexPath.row].modifiedImage
        self.navigationController?.pushViewController(memeDetailsViewController, animated: true)
    }
}
