//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

#if canImport(FluentUI_common)
import FluentUI_common
#endif
import UIKit

class CommandBarButton: UIButton {
    let item: CommandBarItem

    unowned let tokenSet: CommandBarTokenSet

    override var isHighlighted: Bool {
        didSet {
            updateStyle()
        }
    }

    override var isSelected: Bool {
        didSet {
            updateStyle()
        }
    }

    override var isEnabled: Bool {
        didSet {
            updateStyle()
        }
    }

    open override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        updateStyle()
    }

    init(item: CommandBarItem, isPersistSelection: Bool = true, tokenSet: CommandBarTokenSet) {
        self.item = item
        self.isPersistSelection = isPersistSelection
        self.tokenSet = tokenSet

        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false

        if let makeCustomButtonView = item.customControlView {
            addCustomView(makeCustomButtonView())
            /// Disable accessiblity for the button so that the custom view can provide itself or its subviews as the accessilbity element(s)
            isAccessibilityElement = false
        } else {
            var buttonConfiguration = UIButton.Configuration.plain()
            buttonConfiguration.imagePadding = CommandBarTokenSet.buttonImagePadding
            buttonConfiguration.contentInsets = CommandBarTokenSet.buttonContentInsets
            buttonConfiguration.background.cornerRadius = 0
            configuration = buttonConfiguration

            setContentHuggingPriority(.required, for: .horizontal)
            setContentCompressionResistancePriority(.required, for: .horizontal)

            let accessibilityDescription = item.accessibilityLabel
            accessibilityLabel = (accessibilityDescription != nil) ? accessibilityDescription : item.title
            accessibilityHint = item.accessibilityHint
            accessibilityValue = item.accessibilityValue

            /// Large content viewer
            addInteraction(UILargeContentViewerInteraction())
            showsLargeContentViewer = true
            scalesLargeContentImage = true
            largeContentImage = item.iconImage
            largeContentTitle = item.title

            menu = item.menu
            showsMenuAsPrimaryAction = item.showsMenuAsPrimaryAction
        }

        updateState()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        preconditionFailure("init(coder:) has not been implemented")
    }

    func updateState() {
        isEnabled = item.isEnabled
        isSelected = isPersistSelection && item.isSelected
        isHidden = item.isHidden

        /// Additional state update is not needed if the `customControlView` is being shown
        guard item.customControlView == nil else {
            return
        }

        configuration?.title = item.title
        configuration?.image = item.iconImage

        if let font = item.titleFont {
            let attributeContainer = AttributeContainer([NSAttributedString.Key.font: font])
            configuration?.attributedTitle?.setAttributes(attributeContainer)
        }

        updateAccentImage(item.accentImage)
        updateAccentImageTint(item.accentImageTintColor)

        titleLabel?.isEnabled = isEnabled

        let accessibilityDescription = item.accessibilityLabel
        accessibilityLabel = (accessibilityDescription != nil) ? accessibilityDescription : item.title
        accessibilityHint = item.accessibilityHint
        accessibilityValue = item.accessibilityValue
        accessibilityIdentifier = item.accessibilityIdentifier
        menu = item.menu
    }

    private let isPersistSelection: Bool

    private var accentImageView: UIImageView?

    private func updateAccentImage(_ accentImage: UIImage?) {
        if accentImage == accentImageView?.image {
            return
        }

        if let accentImage = accentImage?.withRenderingMode(.alwaysTemplate), let imageView = imageView {
            let accentImageView = UIImageView(image: accentImage)
            accentImageView.translatesAutoresizingMaskIntoConstraints = false
            insertSubview(accentImageView, belowSubview: imageView)
            NSLayoutConstraint.activate([
                accentImageView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
                accentImageView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
            ])
            self.accentImageView = accentImageView
        } else {
            accentImageView?.removeFromSuperview()
            accentImageView = nil
        }
    }

    private func updateAccentImageTint(_ tintColor: UIColor?) {
        guard let tintColor = tintColor else {
            return
        }
        accentImageView?.tintColor = tintColor
    }

    func updateStyle() {
        // TODO: Once iOS 14 support is dropped, this should be converted to a constant (let) that will be initialized by the logic below.
        var resolvedBackgroundColor: UIColor = .clear
        let resolvedTintColor = isSelected ? tokenSet[.itemIconColorSelected].uiColor : tokenSet[.itemIconColorRest].uiColor

        if isPersistSelection {
            if isSelected {
                resolvedBackgroundColor = tokenSet[.itemBackgroundColorSelected].uiColor
            } else if isHighlighted {
                resolvedBackgroundColor = tokenSet[.itemBackgroundColorPressed].uiColor
            } else {
                resolvedBackgroundColor = tokenSet[.itemBackgroundColorRest].uiColor
            }
        }

        configuration?.baseForegroundColor = resolvedTintColor
        configuration?.background.backgroundColor = resolvedBackgroundColor
    }

    private func addCustomView(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)

        /// Constrain view to edges of the button
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor),
            view.topAnchor.constraint(equalTo: topAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private struct LayoutConstants {
        static let contentEdgeInsets = UIEdgeInsets(top: 8.0,
                                                    left: 10.0,
                                                    bottom: 8.0,
                                                    right: 10.0)
    }
}

// MARK: CommandBarButton UIPointerInteractionDelegate

extension CommandBarButton: UIPointerInteractionDelegate {
    public func pointerInteraction(_ interaction: UIPointerInteraction, willEnter region: UIPointerRegion, animator: UIPointerInteractionAnimating) {
        backgroundColor = isSelected ? tokenSet[.itemBackgroundColorSelected].uiColor : tokenSet[.itemBackgroundColorHover].uiColor
        tintColor = isSelected ? tokenSet[.itemIconColorSelected].uiColor : tokenSet[.itemIconColorHover].uiColor
    }

    public func pointerInteraction(_ interaction: UIPointerInteraction, willExit region: UIPointerRegion, animator: UIPointerInteractionAnimating) {
        updateStyle()
    }
}
