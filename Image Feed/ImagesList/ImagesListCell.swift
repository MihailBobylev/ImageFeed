import UIKit
import Kingfisher
import SnapKit

public protocol ImagesListCellProtocol {
    func setIsLiked(isLiked: Bool)
    func makeGradientLayer()
    func removeGradientLayer()
}

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCellProtocol)
}

public final class ImagesListCell: UITableViewCell, ImagesListCellProtocol {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    
    private lazy var likeButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(changeLikeTap), for: .touchUpInside)
        return button
    }()
    
    private var gradientAnimationLayer: CALayer?
    
    weak var delegate: ImagesListCellDelegate?
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        cellImage.kf.cancelDownloadTask()
        dateLabel.text = nil
        setIsLiked(isLiked: false)
        removeGradientLayer()
    }
}

public extension ImagesListCell {
    func configure() {
        contentView.addSubview(likeButton)
        likeButton.snp.makeConstraints { make in
            make.height.width.equalTo(44)
            make.top.trailing.equalTo(cellImage)
        }
    }
    
    func setIsLiked(isLiked: Bool) {
        let likeImage = isLiked ? UIImage(resource: .likeButtonOn) : UIImage(resource: .likeButtonOff)
        likeButton.setImage(likeImage, for: .normal)
    }
    
    func makeGradientLayer() {
        gradientAnimationLayer = cellImage.addGradientPlaceholder(in: contentView.bounds, withRadius: 16)
    }
    
    func removeGradientLayer() {
        gradientAnimationLayer?.removeFromSuperlayer()
        gradientAnimationLayer = nil
    }
}

private extension ImagesListCell {
    @objc func changeLikeTap(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
}
