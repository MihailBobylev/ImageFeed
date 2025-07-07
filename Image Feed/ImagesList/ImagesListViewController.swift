import UIKit
import Kingfisher
import ProgressHUD

public protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    func configure(_ presenter: ImagesListPresenterProtocol)
    func updateTableViewAnimated(oldCount: Int, newCount: Int)
    func setIsLiked(isLiked: Bool, on cell: ImagesListCellProtocol)
    func showChangeLikeError()
}

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    private enum Constants {
        static let showSingleImageSegueIdentifier = "ShowSingleImage"
    }
    
    @IBOutlet private var tableView: UITableView!
    var presenter: ImagesListPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        presenter?.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == Constants.showSingleImageSegueIdentifier else {
            super.prepare(for: segue, sender: sender)
            return
        }
        guard let viewController = segue.destination as? SingleImageViewController,
              let indexPath = sender as? IndexPath
        else {
            assertionFailure("Invalid segue destination")
            return
        }
        viewController.fullImageURLString = presenter?.photos[indexPath.row].largeImageURL
    }
    
    func configure(_ presenter: ImagesListPresenterProtocol) {
        self.presenter = presenter
        self.presenter?.view = self
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.photos.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let imageListCell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        
        return imageListCell
    }
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let currentPhoto = presenter?.photos[indexPath.row] else { return }
        cell.configure()
        cell.makeGradientLayer()
        cell.cellImage.kf.setImage(with: URL(string: currentPhoto.thumbImageURL),
                                   options: [.transition(.fade(0.3))]) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                print("[ImagesListViewController.configCell]: \(error)")
                cell.cellImage.image = UIImage(resource: .placeholderForImageListCell)
            }
            cell.removeGradientLayer()
        }
        
        if let createdAt = currentPhoto.createdAt {
            cell.dateLabel.text = DateFormatter.longStyle.string(from: createdAt)
        } else {
            cell.dateLabel.text = nil
        }
        
        cell.setIsLiked(isLiked: currentPhoto.isLiked)
        cell.delegate = self
    }
    
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        tableView.performBatchUpdates {
            let indexPaths = (oldCount..<newCount).map { i in
                IndexPath(row: i, section: 0)
            }
            tableView.insertRows(at: indexPaths, with: .automatic)
        } completion: { _ in }
    }
    
    func setIsLiked(isLiked: Bool, on cell: ImagesListCellProtocol) {
        cell.setIsLiked(isLiked: isLiked)
    }
    
    func showChangeLikeError() {
        AlertPresenter.showChangeLikeError(in: self)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Constants.showSingleImageSegueIdentifier, sender: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let photoSize = presenter?.photos[indexPath.row].size else { return 0 }
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photoSize.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photoSize.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.row == (presenter?.photos.count ?? 0) - 1 else { return }
        presenter?.fetchPhotosNextPage()
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCellProtocol) {
        guard let realCell = cell as? UITableViewCell, let indexPath = tableView.indexPath(for: realCell) else { return }
        presenter?.changeLike(on: indexPath, cell)
    }
}
