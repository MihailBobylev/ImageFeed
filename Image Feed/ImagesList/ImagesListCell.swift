import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    
    private var gradientAnimationLayer: CALayer?
    
    weak var delegate: ImagesListCellDelegate?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellImage.kf.cancelDownloadTask()
        dateLabel.text = nil
        setIsLiked(isLiked: false)
        removeGradientLayer()
    }
    
    @IBAction private func changeLikeTap(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
}

extension ImagesListCell {
    func setIsLiked(isLiked: Bool) {
        let likeImage = isLiked ? UIImage(resource: .likeButtonOn) : UIImage(resource: .likeButtonOff)
        likeButton.setImage(likeImage, for: .normal)
    }
    
    func makeGradientLayer() {
        gradientAnimationLayer = addGradientPlaceholder(to: cellImage, in: contentView.bounds, withRadius: 16)
    }
    
    func removeGradientLayer() {
        gradientAnimationLayer?.removeFromSuperlayer()
        gradientAnimationLayer = nil
    }
}

private extension ImagesListCell {
    func addGradientPlaceholder(to view: UIView, in rect: CGRect, withRadius radius: CGFloat) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = rect
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = radius
        gradient.masksToBounds = true
        
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        gradient.add(gradientChangeAnimation, forKey: "locationsChange")
        
        view.layer.addSublayer(gradient)
        
        return gradient
    }
}
