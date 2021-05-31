import UIKit

class MainViewController: UIViewController {
    
    // MARK: - Outlets

    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var wetherDescription: UILabel!
    
    @IBOutlet weak var airTemperature: UILabel!
    
    @IBOutlet weak var maxMinTemperatureToday: UILabel!
    
    @IBOutlet weak var temperatureStackView: UIStackView!
    
    @IBOutlet weak var locationStackView: UIStackView!
    
    @IBOutlet weak var locationStackViewConstraintTop: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        
        let nib = UINib(nibName: String(describing: MainTableViewCell.self), bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: MainTableViewCell.cellID)
        
        
    }


}

// MARK: - UITableViewDataSource

extension MainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.cellID, for: indexPath) as? MainTableViewCell
        else {
            fatalError("Can not find cell with id: \(MainTableViewCell.cellID) at indexPath: \(indexPath)")
        }
        
        cell.titleLabel.text = "Восход солнца"
        cell.infoWetherLabel.text = "04:45"
        
        return cell
    }
    
    
    
}


// MARK: - UITableViewDelegate

extension MainViewController: UITableViewDelegate {
    
    
    
}

// MARK: - UIScrollViewDelegate

extension MainViewController: UIScrollViewDelegate {
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        let fi
        
        if offset <
    }
    
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//
//        let contentOffset = locationStackView.frame.size.height + locationStackViewConstraintTop.constant
//
//
//        scrollView.setContentOffset(CGPoint(x: 0, y: contentOffset), animated: true)
//    }
}

