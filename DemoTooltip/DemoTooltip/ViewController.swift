//
//  ViewController.swift
//  DemoTooltip
//
//  Created by vikram depawat on 26/04/23.
//

import UIKit
import AMPopTip

class ViewController: UIViewController {
    let textDescription = "A label can contain an arbitrary amount of text, but UILabel may shrink, wrap, or truncate the text, depending on the size of the bounding rectangle and properties you set. You can control the font, text color, alignment, highlighting, and shadowing of the text in the label. You can control the font, text color, alignment, highlighting, and shadowing of the text in the label. You can control the font, text color, alignment, highlighting, and shadowing of the text in the label."
    private let popTip = PopTip()
    @IBOutlet weak var lblMoreText: UILabel! {
        didSet {
            lblMoreText.font = UIFont.systemFont(ofSize: 15)
            lblMoreText.textColor = .black
            lblMoreText.numberOfLines = 2
            lblMoreText.isUserInteractionEnabled = true
        }
    }

    private var popupView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapLabel(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        lblMoreText.addGestureRecognizer(tapGestureRecognizer)
        lblMoreText.appendReadmore(after: textDescription, trailingContent: .readmore)
        popTip.bubbleColor = .systemRed
        popTip.arrowSize = CGSize(width: 19.0, height: 11.0)
    }

    private func setPopupView(frame: CGRect) {
        popupView = UIView(frame: CGRect(x: 0, y: 0, width: 240, height: 250))
        let label = UILabel(frame: CGRect(x: 10, y: 10, width: 220, height: 230))
        label.text = textDescription
        label.textColor = .white
        label.font = .systemFont(ofSize: 12)
        label.numberOfLines = 0
        popupView.addSubview(label)
        popTip.show(customView: popupView, direction: .down, in: self.view, from: frame)
        popTip.shouldDismissOnTap = true
        popTip.entranceAnimationHandler = { [weak self] completion in
            guard let `self` = self else { return }
            self.popTip.transform = CGAffineTransform(rotationAngle: 0.3)
            UIView.animate(
                withDuration: 0.5,
                animations: {
                    self.popTip.transform = .identity
                },
                completion: { _ in
                    completion()
                }
            )
        }
    }

    @objc
    @IBAction func didTapLabel(_ sender: UITapGestureRecognizer) {
            guard let text = lblMoreText.text else { return }
            let readmore = (text as NSString).range(of: TrailingContent.readmore.text)
            if sender.didTap(label: lblMoreText, inRange: readmore) {
                let frame = lblMoreText.boundingRectForCharacterRange(readmore) ?? CGRect(x: 50, y: 50, width: 50, height: 50)
                setPopupView(frame: frame)
            }
        }
}

extension UITapGestureRecognizer {

    func didTap(label: UILabel, inRange targetRange: NSRange) -> Bool {

        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)

        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize

        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)

        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)

        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
}https://github.com/vikramsinghcharan/DemoToolTip
