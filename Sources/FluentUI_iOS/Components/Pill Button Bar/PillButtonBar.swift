//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

#if canImport(FluentUI_common)
import FluentUI_common
#endif
import UIKit

// MARK: PillButtonBarItem

/// `PillButtonBarItem` is an item that can be presented as a pill shaped text button.
@objc(MSFPillButtonBarItem)
open class PillButtonBarItem: NSObject {

    /// Creates a new instance of the PillButtonBarItem that holds data used to create a pill button in a PillButtonBar.
    /// - Parameter title: Title that will be displayed by a pill button in the PillButtonBar.
    @objc public init(title: String) {
        self.title = title
        super.init()
    }

    /// Creates a new instance of the PillButtonBarItem that holds data used to create a pill button in a PillButtonBar.
    /// - Parameters:
    ///   - title: Title that will be displayed by a pill button in the PillButtonBar.
    ///   - isUnread: Whether the pill button shows the mark that represents the "unread" state.
    @objc public convenience init(title: String, isUnread: Bool = false) {
        self.init(title: title)
        self.isUnread = isUnread
    }

    /// Title that will be displayed in the button.
    @objc public var title: String {
        didSet {
            if oldValue != title {
                NotificationCenter.default.post(name: PillButtonBarItem.titleValueDidChangeNotification, object: self)
            }
        }
    }

    /// This value will determine whether or not to show the mark that represents the "unread" state (dot next to the pill button label).
    /// The default value of this property is false.
    public var isUnread: Bool = false {
       didSet {
           if oldValue != isUnread {
               NotificationCenter.default.post(name: PillButtonBarItem.isUnreadValueDidChangeNotification, object: self)
           }
       }
   }

    /// Notification sent when item's `isUnread` value changes.
    static let isUnreadValueDidChangeNotification = NSNotification.Name(rawValue: "PillButtonBarItemisUnreadValueDidChangeNotification")

    /// Notification sent when item's `title` value changes.
    static let titleValueDidChangeNotification = NSNotification.Name(rawValue: "PillButtonBarItemTitleValueDidChangeNotification")
}

// MARK: PillButtonBar

/// `PillButtonBar` is a horizontal scrollable list of pill shape text buttons in which only one button can be selected at a given time.
/// Set the `items` property to determine what buttons will be shown in the bar. Each `PillButtonBarItem` will be represented as a button.
/// Set the `delegate` property to listen to selection changes.
/// Set the `selectedItem` property if the selection needs to be programatically changed.
/// Once a button is selected, the previously selected button will be deselected.
@objc(MSFPillButtonBar)
open class PillButtonBar: UIScrollView {
    open override func layoutSubviews() {
        super.layoutSubviews()

        if bounds.width == 0 {
            return
        }

        if needsButtonSizeReconfiguration {
            ensureMinimumButtonWidth()
            updateHeightConstraint()
            adjustButtonsForCurrentScrollFrame()
            needsButtonSizeReconfiguration = false
            if let selectedButton = selectedButton {
                layoutIfNeeded()
                scrollButtonToVisible(selectedButton)
            }
        }
    }

    /// Initializes the PillButtonBar using the provided style.
    ///
    /// - Parameters:
    ///   - pillButtonStyle: The style override for the pill buttons in this pill button bar
    @objc public init(pillButtonStyle: PillButtonStyle = .primary) {
        self.pillButtonStyle = pillButtonStyle
        super.init(frame: .zero)
        setupScrollView()
        setupStackView()

        let pointerInteraction = UIPointerInteraction(delegate: self)
        addInteraction(pointerInteraction)
    }

    public required init?(coder aDecoder: NSCoder) {
        preconditionFailure("init(coder:) has not been implemented")
    }

    @objc public func selectItem(_ item: PillButtonBarItem) {
        guard let index = indexOfButtonWithItem(item) else {
            return
        }

        selectedButton = buttons[index]
    }

    @objc public func selectItem(atIndex index: Int) -> Bool {
        if index < 0 || index >= buttons.count {
            return false
        }

        selectedButton = buttons[index]
        return true
    }

    @objc public func disableItem(_ item: PillButtonBarItem) {
        guard let index = indexOfButtonWithItem(item) else {
            return
        }

        buttons[index].isEnabled = false
    }

    @objc public func disableItem(atIndex index: Int) {
        if index < 0 || index >= buttons.count {
            return
        }

        buttons[index].isEnabled = false
    }

    @objc public func enableItem(_ item: PillButtonBarItem) {
        guard let index = indexOfButtonWithItem(item) else {
            return
        }

        buttons[index].isEnabled = true
    }

    @objc public func enableItem(atIndex index: Int) {
        if index < 0 || index >= buttons.count {
            return
        }

        buttons[index].isEnabled = true
    }

    @objc public weak var barDelegate: PillButtonBarDelegate?

    @objc public var centerAligned: Bool = false {
        didSet {
            adjustAlignment()
        }
    }

    @objc public var items: [PillButtonBarItem]? {
        didSet {
            clearButtons()

            if let items = items {
                addButtonsWithItems(items)
            }

            setNeedsLayout()
            needsButtonSizeReconfiguration = true
        }
    }

    @objc public let pillButtonStyle: PillButtonStyle

    public var pillButtonOverrideTokens: [PillButtonTokenSet.Tokens: ControlTokenValue]? {
        didSet {
            updatePillButtonAppearance()
        }
    }

    /// If set to nil, the previously selected item will be deselected and there won't be any items selected
    @objc public var selectedItem: PillButtonBarItem? {
        get {
            return selectedButton?.pillBarItem
        }
        set {
            if let item = newValue, let index = indexOfButtonWithItem(item) {
                selectedButton = buttons[index]
            }
        }
    }

    private var buttonExtraSidePadding: CGFloat = 0.0

    private var buttons = [PillButton]()

    private var needsButtonSizeReconfiguration: Bool = false

    private var selectedButton: PillButton? {
        willSet {
            selectedButton?.isSelected = false
        }

        didSet {
            if let button = selectedButton {
                button.isSelected = true
            }
        }
    }

    private lazy var stackView: UIStackView = initStackView()

    private struct Constants {
        /// Maximum spacing between `PillButton` controls
        static let maxButtonsSpacing: CGFloat = 10.0

        /// Minimum spacing between `PillButton` controls
        static let minButtonsSpacing: CGFloat = GlobalTokens.spacing(.size80)

        /// Minimum width of the last button that must be showing on screen when the `PillButtonBar` loads or redraws
        static let minButtonVisibleWidth: CGFloat = GlobalTokens.spacing(.size200)

        /// Minimum width of a `PillButton`
        static let minButtonWidth: CGFloat = 56.0

        /// Minimum height of the `PillButtonBar`
        static let minHeight: CGFloat = 28.0

        /// Offset from the leading edge when the `PillButtonBar` loads or redraws
        static let sideInset: CGFloat = GlobalTokens.spacing(.size160)
    }

    private func initStackView() -> UIStackView {
        let view = UIStackView()
        view.alignment = .center
        view.distribution = .fillProportionally
        view.spacing = Constants.minButtonsSpacing
        return view
    }

    private func addButtonsWithItems(_ items: [PillButtonBarItem]) {
        for (index, item) in items.enumerated() {
            let button = createButtonWithItem(item)
            buttons.append(button)
            stackView.addArrangedSubview(button)

            let shouldAddAccessibilityHint = !self.accessibilityTraits.contains(.tabBar)
            if shouldAddAccessibilityHint {
                button.accessibilityHint = String.localizedStringWithFormat("Accessibility.MSPillButtonBar.Hint".localized, index + 1, items.count)
            }
        }
    }

    private func adjustAlignment() {
        leadingConstraint?.isActive = !centerAligned
        trailingConstraint?.isActive = !centerAligned
        centerConstraint?.isActive = centerAligned

        contentInset.left = centerAligned ? 0.0 : Constants.sideInset
        contentInset.right = contentInset.left
        scrollToOrigin()
    }

    ///  If necessary, adjusts the spacing and padding of the first few visible buttons in the scroll frame so that the portion
    ///  of the last button visible clearly indicates that there are more buttons that can be scrolled into the view.
    ///
    ///  Buttons in the scroll view are of variable widths. When the initial list of buttons is displayed horizontally, it is uncertain
    ///  when the list will be cut off at the trailing edge. We must optimize it so that the last button shown has an appropriate
    ///  portion of it visible and there's a clear indication that the view is scrollable. To achieve this, this function calculates
    ///  a new spacing and padding that will shift the last visible button farther in the view.
    private func adjustButtonsForCurrentScrollFrame() {
        var visibleWidth = frame.width - (Constants.minButtonsSpacing + Constants.minButtonVisibleWidth)
        var visibleButtonsWidth: CGFloat = Constants.sideInset
        var visibleButtonCount = 0
        for button in buttons {
            button.layoutIfNeeded()
            visibleButtonsWidth += button.frame.width
            visibleButtonCount += 1
            if visibleButtonsWidth > visibleWidth {
                break
            }

            visibleButtonsWidth += Constants.minButtonsSpacing
        }

        if visibleButtonCount == buttons.count {
            // If the last visible button is the last button, not need to account for space in a next button
            visibleWidth += Constants.minButtonVisibleWidth
        }

        if visibleButtonsWidth <= visibleWidth {
            // No enough buttons to fill the scroll frame
            return
        }

        let optimalVisibleButtonWidth = frame.width + Constants.minButtonVisibleWidth
        let totalAdjustment = optimalVisibleButtonWidth - visibleButtonsWidth
        if totalAdjustment < 0.0 {
            return
        }

        let numberOfButtonsToAdjust = visibleButtonCount - 1
        let adjustedSpace = adjustButtonsSpacing(totalSpace: totalAdjustment, numberOfButtons: numberOfButtonsToAdjust)
        let reminderToAdjust = totalAdjustment - adjustedSpace
        if reminderToAdjust > 0 {
            adjustButtonsSidePadding(totalPadding: reminderToAdjust, numberOfButtons: numberOfButtonsToAdjust)
        }
    }

    /// Increases the left and right content inset of all the buttons, so that the sum of the extra space added in the first numberOfButtons
    /// buttons accounts for the totalAdjustment needed.
    /// - Parameter totalPadding: The total padding needed before the first numberOfButtons buttons
    /// - Parameter numberOfButtons: The number of buttons that should allocate the totalPadding change
    private func adjustButtonsSidePadding(totalPadding: CGFloat, numberOfButtons: Int) {
        let buttonEdges = (numberOfButtons * 2) + 1
        buttonExtraSidePadding = ceil(totalPadding / CGFloat(buttonEdges))
        for button in buttons {
            button.layoutIfNeeded()

            button.configuration?.contentInsets.leading += buttonExtraSidePadding
            button.configuration?.contentInsets.trailing += buttonExtraSidePadding

            button.layoutIfNeeded()
        }
    }

    /// Attempts to increase the spacing between all buttons, so that the sum of the extra space added before on the first numberOfButtons
    /// buttons accounts for the totalAdjustment needed. If the spacing needed for all the buttons is larger than the maxium spacing
    /// allowed, the maxium spacing will be used.
    /// - Parameter totalSpace: The total spacing needed before the first numberOfButtons buttons
    /// - Parameter numberOfButtons: The number of buttons that should allocate the totalSpace change
    /// - Returns: The total space adjusted before the first numberOfButtons buttons
    private func adjustButtonsSpacing(totalSpace: CGFloat, numberOfButtons: Int) -> CGFloat {
        if numberOfButtons == 0 {
            return 0.0
        }

        let spacingAdjustment = ceil((totalSpace) / CGFloat(numberOfButtons))
        let newSpacing = min(Constants.maxButtonsSpacing, Constants.minButtonsSpacing + spacingAdjustment)
        let spacingChange = newSpacing - stackView.spacing
        stackView.spacing = newSpacing
        return spacingChange * CGFloat(numberOfButtons)
    }

    private func clearButtons() {
        selectedButton = nil
        buttons.forEach { $0.removeFromSuperview() }
        buttons.removeAll()
    }

    private func createButtonWithItem(_ item: PillButtonBarItem) -> PillButton {
        let button = PillButton(pillBarItem: item, style: pillButtonStyle, tokenOverrides: pillButtonOverrideTokens)
        button.addTarget(self, action: #selector(selectButton(_:)), for: .touchUpInside)
        return button
    }

    private func ensureMinimumButtonWidth() {
        for button in buttons {
            button.layoutIfNeeded()
            let buttonWidth = button.frame.width
            if buttonWidth > 0, buttonWidth < Constants.minButtonWidth {
                let extraInset = floor((Constants.minButtonWidth - button.frame.width) / 2)

                button.configuration?.contentInsets.leading += extraInset
                button.configuration?.contentInsets.trailing = button.configuration?.contentInsets.leading ?? extraInset

                button.layoutIfNeeded()
            }
        }
    }

    private func indexOfButtonWithItem(_ item: PillButtonBarItem) -> Int? {
        for (index, button) in buttons.enumerated() {
            if button.pillBarItem == item {
                return index
            }
        }

        return nil
    }

    private func setupScrollView() {
        if effectiveUserInterfaceLayoutDirection == .rightToLeft {
            transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        }

        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false

        addInteraction(UILargeContentViewerInteraction())
    }

    private func setupStackView() {
        if effectiveUserInterfaceLayoutDirection == .rightToLeft {
            stackView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        }

        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        leadingConstraint = stackView.leadingAnchor.constraint(equalTo: leadingAnchor)
        trailingConstraint = stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        centerConstraint = stackView.centerXAnchor.constraint(equalTo: centerXAnchor)

        heightConstraint = heightAnchor.constraint(equalToConstant: Constants.minHeight)
        heightConstraint?.isActive = true

        adjustAlignment()
    }

    /// If the button is not fully visible in the scroll frame, scrolls the view by an offset large enough so that
    /// both the button and a peek of its following button become visible.
    private func scrollButtonToVisible(_ button: PillButton) {
        let buttonFrame = button.convert(button.bounds, to: self)
        let buttonLeftPosition = buttonFrame.origin.x
        let buttonRightPosition = buttonLeftPosition + button.frame.size.width
        let viewLeadingPosition = bounds.origin.x
        let viewTrailingPosition = viewLeadingPosition + frame.size.width

        let extraScrollWidth = Constants.minButtonVisibleWidth + stackView.spacing + buttonExtraSidePadding
        var offSet = contentOffset.x
        if buttonLeftPosition < viewLeadingPosition {
            offSet = buttonLeftPosition - extraScrollWidth
            offSet = max(offSet, -Constants.sideInset)
        } else if buttonRightPosition > viewTrailingPosition {
            let maxOffsetX = contentSize.width - frame.size.width + Constants.sideInset
            offSet = buttonRightPosition - frame.size.width + extraScrollWidth
            offSet = min(offSet, maxOffsetX)
        }

        if offSet != contentOffset.x {
            setContentOffset(CGPoint(x: offSet, y: contentOffset.y), animated: true)
        }
    }

    private func scrollToOrigin(animated: Bool = false) {
        let originX: CGFloat = centerAligned ? 0.0 : -contentInset.left
        setContentOffset(CGPoint(x: originX, y: contentOffset.y), animated: animated)
    }

    @objc private func selectButton(_ button: PillButton) {
        selectedButton = button
        scrollButtonToVisible(button)
        if let index = buttons.firstIndex(of: button) {
            barDelegate?.pillBar?(self, didSelectItem: button.pillBarItem, atIndex: index)
        }
    }

    private func updateHeightConstraint() {
        var maxHeight: CGFloat = Constants.minHeight
        buttons.forEach { maxHeight = max(maxHeight, $0.frame.size.height) }
        if let heightConstraint = heightConstraint, maxHeight != heightConstraint.constant {
            heightConstraint.constant = maxHeight
        }
    }

    private func updatePillButtonAppearance() {
        for button in buttons {
            button.tokenSet.replaceAllOverrides(with: pillButtonOverrideTokens)
        }
    }

    private var leadingConstraint: NSLayoutConstraint?

    private var centerConstraint: NSLayoutConstraint?

    private var heightConstraint: NSLayoutConstraint?

    private var trailingConstraint: NSLayoutConstraint?
}

// MARK: PillButtonBar UIPointerInteractionDelegate

extension PillButtonBar: UIPointerInteractionDelegate {
    public func pointerInteraction(_ interaction: UIPointerInteraction, regionFor request: UIPointerRegionRequest, defaultRegion: UIPointerRegion) -> UIPointerRegion? {
        var region: UIPointerRegion?

        for (index, button) in buttons.enumerated() {
            if button.isEnabled {
                var frame = button.frame
                frame = stackView.convert(frame, to: self)

                if frame.contains(request.location) {
                    region = UIPointerRegion(rect: frame, identifier: index)
                    break
                }
            }
        }

        return region
    }

    public func pointerInteraction(_ interaction: UIPointerInteraction, styleFor region: UIPointerRegion) -> UIPointerStyle? {
        guard let superview = window, let index = region.identifier as? Int, index < buttons.count else {
            return nil
        }

        let pillButton = buttons[index]
        let pillButtonFrame = stackView.convert(pillButton.frame, to: superview)
        let target = UIPreviewTarget(container: superview, center: CGPoint(x: pillButtonFrame.midX, y: pillButtonFrame.midY))
        let preview = UITargetedPreview(view: pillButton, parameters: UIPreviewParameters(), target: target)
        let pointerEffect = UIPointerEffect.lift(preview)

        return UIPointerStyle(effect: pointerEffect, shape: nil)
    }
}

// MARK: PillButtonBarDelegate

@objc(MSFPillButtonBarDelegate)
public protocol PillButtonBarDelegate {
    /// Called after the button representing the item is tapped in the UI.
    @objc optional func pillBar(_ pillBar: PillButtonBar, didSelectItem item: PillButtonBarItem, atIndex index: Int)
}
