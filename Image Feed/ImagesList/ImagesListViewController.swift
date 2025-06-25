import UIKit
import Kingfisher
import ProgressHUD

final class ImagesListViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!

    private let imagesListService = ImagesListService.shared
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    private var photos: [Photo] = []
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { _ in
                self.updateTableViewAnimated()
            }
        
        guard let token = oauth2TokenStorage.token else {
            print("[ImagesListViewController.viewDidLoad]: No auth token")
            return
        }
        
        imagesListService.fetchPhotosNextPage(authToken: token)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            viewController.fullImageURLString = photos[indexPath.row].largeImageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
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
        let currentPhoto = photos[indexPath.row]
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
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photoSize = photos[indexPath.row].size
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photoSize.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photoSize.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            guard let token = oauth2TokenStorage.token else {
                print("[tableView.willDisplay]: No auth token")
                return
            }
            
            imagesListService.fetchPhotosNextPage(authToken: token)
        }
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let token = oauth2TokenStorage.token else {
            print("[imageListCellDidTapLike]: No auth token")
            return
        }
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked, authToken: token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self else { return }
            switch result {
            case .success:
                photos = imagesListService.photos
                cell.setIsLiked(isLiked: photos[indexPath.row].isLiked)
            case .failure:
                AlertPresenter.showChangeLikeError(in: self)
            }
        }
    }
}

private extension ImagesListViewController {
    func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
}
