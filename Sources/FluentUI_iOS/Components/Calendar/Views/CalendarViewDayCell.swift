//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

#if canImport(FluentUI_common)
import FluentUI_common
#endif
import UIKit

// MARK: CalendarViewDayCellTextStyle

enum CalendarViewDayCellTextStyle {
    case primary
    case secondary
}

// MARK: - CalendarViewDayCellBackgroundStyle

enum CalendarViewDayCellBackgroundStyle {
    case primary
    case secondary
}

// MARK: - CalendarViewDayCellVisualState

enum CalendarViewDayCellVisualState {
    case normal          // Collapsed `.Short` style
    case normalWithDots  // Expanded `.Tall` style
    case fadedWithDots   // Expanded `.Half` or `.Tall` style during user interaction
}

// MARK: - CalendarViewDayCellSelectionType

enum CalendarViewDayCellSelectionType {
    case singleSelection
    case startOfRangedSelection
    case middleOfRangedSelection
    case endOfRangedSelection
}

// MARK: - CalendarViewDayCellSelectionStyle

enum CalendarViewDayCellSelectionStyle {
    case normal
    case freeAtSpecificTimeSlot
    case freeAtDifferentTimeSlot
    case busy
    case unknown
}

let calendarViewDayCellVisualStateTransitionDuration: TimeInterval = 0.3

// MARK: - CalendarViewDayCell

class CalendarViewDayCell: UICollectionViewCell, TokenizedControl {
    struct Constants {
        static let borderWidth: CGFloat = 0.5
        static let dotDiameter: CGFloat = 6.0
        static let fadedVisualStateAlphaMultiplier: CGFloat = 0.2
    }

    class var identifier: String { return "CalendarViewDayCell" }

    override var isSelected: Bool {
        didSet {
            selectionOverlayView.selected = isSelected
            updateViews()
        }
    }

    override var isHighlighted: Bool {
        didSet {
            selectionOverlayView.highlighted = isHighlighted
            updateViews()
        }
    }

    private(set) var textStyle: CalendarViewDayCellTextStyle = .primary
    private(set) var backgroundStyle: CalendarViewDayCellBackgroundStyle = .primary

    private var visibleDotViewAlpha: CGFloat = 1.0

    private let selectionOverlayView: SelectionOverlayView
    let dateLabel: UILabel
    let dotView: DotView

    typealias TokenSetKeyType = EmptyTokenSet.Tokens
    let tokenSet: EmptyTokenSet = .init()

    override init(frame: CGRect) {
        // Initialize subviews
        //
        // Disable user interaction to allow gestures to fall through to the collection view
        // and collection view cell especially during animation. This is protect against
        // subviews that default `userInteractionEnabled` to true (UIView).

        selectionOverlayView = SelectionOverlayView()
        selectionOverlayView.isUserInteractionEnabled = false

        dateLabel = UILabel(frame: .zero)
        dateLabel.textAlignment = .center
        dateLabel.showsLargeContentViewer = true

        dotView = DotView()
        dotView.alpha = 0.0  // Initial `visualState` is `.Normal` without dots
        dotView.isUserInteractionEnabled = false

        super.init(frame: frame)

        dateLabel.font = fluentTheme.typography(.body1)
        dotView.color = tokenSet.fluentTheme.color(.foreground3)
        dateLabel.textColor = tokenSet.fluentTheme.color(.foreground3)

        contentView.addSubview(selectionOverlayView)
        contentView.addSubview(dateLabel)
        contentView.addSubview(dotView)

        tokenSet.registerOnUpdate(for: self) { [weak self] in
            self?.updateAppearance()
        }
    }

    func updateAppearance() {
        updateViews()
        dotView.color = tokenSet.fluentTheme.color(.foreground3)
        dateLabel.textColor = tokenSet.fluentTheme.color(.foreground3)
    }

    required init?(coder aDecoder: NSCoder) {
        preconditionFailure("init(coder:) has not been implemented")
    }

    // Only supports indicator levels from 0...4
    func setup(textStyle: CalendarViewDayCellTextStyle, backgroundStyle: CalendarViewDayCellBackgroundStyle, selectionStyle: CalendarViewDayCellSelectionStyle, dateLabelText: String, indicatorLevel: Int) {
        self.textStyle = textStyle
        self.backgroundStyle = backgroundStyle
        selectionOverlayView.selectionStyle = selectionStyle

        // Assign text content
        dateLabel.text = dateLabelText

        // Assign dot content
        visibleDotViewAlpha = CGFloat(min(indicatorLevel, 4)) / 4.0

        updateViews()
    }

    func setVisualState(_ visualState: CalendarViewDayCellVisualState, animated: Bool) {
        func applyVisualState() {
            switch visualState {
            case .normal:
                contentView.alpha = 1.0
                dateLabel.alpha = 1.0
                dotView.alpha = 0.0
                selectionOverlayView.alpha = 1.0

            case .normalWithDots:
                contentView.alpha = 1.0
                dateLabel.alpha = 1.0
                dotView.alpha = visibleDotViewAlpha
                selectionOverlayView.alpha = 1.0

            case .fadedWithDots:
                contentView.alpha = Constants.fadedVisualStateAlphaMultiplier
                dateLabel.alpha = 1.0
                dotView.alpha = visibleDotViewAlpha
                selectionOverlayView.alpha = 1.0
            }
        }

        if animated {
            UIView.animate(withDuration: calendarViewDayCellVisualStateTransitionDuration, animations: applyVisualState)
        } else {
            applyVisualState()
        }
    }

    func setSelectionType(_ selectionType: CalendarViewDayCellSelectionType) {
        selectionOverlayView.selectionType = selectionType
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        selectionOverlayView.frame = contentView.bounds

        let maxWidth = contentView.bounds.size.width
        let maxHeight = contentView.bounds.size.height

        // Date label
        dateLabel.frame = contentView.bounds

        // Dot view
        dotView.frame = CGRect(
            x: (maxWidth - Constants.dotDiameter) / 2.0,
            y: ((maxHeight - Constants.dotDiameter) / 2.0) + 15.0,
            width: Constants.dotDiameter,
            height: Constants.dotDiameter
        )
    }

    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        guard let newWindow else {
            return
        }
        tokenSet.update(newWindow.fluentTheme)
        updateViews()
    }

    private func updateViews() {
        switch textStyle {
        case .primary:
            dateLabel.textColor = tokenSet.fluentTheme.color(.foreground1)
        case .secondary:
            dateLabel.textColor = tokenSet.fluentTheme.color(.foreground2)
        }

        switch backgroundStyle {
        case .primary:
            contentView.backgroundColor = UIColor(light: tokenSet.fluentTheme.color(.background2).light,
                                                  dark: tokenSet.fluentTheme.color(.background2).dark)
        case .secondary:
            contentView.backgroundColor = UIColor(light: tokenSet.fluentTheme.color(.backgroundCanvas).light,
                                                  dark: tokenSet.fluentTheme.color(.backgroundCanvas).dark)
        }

        if isHighlighted || isSelected {
            dotView.isHidden = true
            dateLabel.textColor = tokenSet.fluentTheme.color(.foregroundOnColor)
        } else {
            dotView.isHidden = false
        }

        selectionOverlayView.activeColor = tokenSet.fluentTheme.color(.brandBackground1)

        setNeedsLayout()
    }
}

// MARK: - SelectionOverlayView

private class SelectionOverlayView: UIView {
    struct Constants {
        static let highlightedOrSelectedCircleMargin: CGFloat = 5.0
    }

    var selectionType: CalendarViewDayCellSelectionType = .singleSelection {
        didSet {
            setupActiveViews()
        }
    }
    var selectionStyle: CalendarViewDayCellSelectionStyle = .normal

    // TODO: Add different colors for availability?
    var selected: Bool = false {
        didSet {
            setupActiveViews()
        }
    }
    var highlighted: Bool = false {
        didSet {
            setupActiveViews()
        }
    }

    var activeColor: UIColor = .clear {
        didSet {
            setupActiveViews()
        }
    }

    // Lazy load views as every additional subview impacts the "Calendar"
    // tab loading time because the MSDatePicker needs
    // to initialize N * 7 cells when loading the view
    private var circleView: DotView?
    private var squareView: UIView?

    override func layoutSubviews() {
        super.layoutSubviews()

        let maxWidth = bounds.size.width
        let maxHeight = bounds.size.height

        let circleDiameter = min(maxWidth, maxHeight) - (2.0 * Constants.highlightedOrSelectedCircleMargin)

        let originY = (maxHeight - circleDiameter) / 2.0
        circleView?.frame = CGRect(x: (maxWidth - circleDiameter) / 2.0, y: originY, width: circleDiameter, height: circleDiameter)

        switch selectionType {
        case .startOfRangedSelection:
            squareView?.frame = CGRect(x: maxWidth / 2, y: originY, width: maxWidth / 2, height: circleDiameter)
        case .middleOfRangedSelection:
            squareView?.frame = CGRect(x: 0, y: originY, width: maxWidth, height: circleDiameter)
        case .endOfRangedSelection:
            squareView?.frame = CGRect(x: 0, y: originY, width: maxWidth / 2, height: circleDiameter)
        case .singleSelection:
            break
        }

        flipSubviewsForRTL()
    }

    private func setupActiveViews() {
        switch selectionType {
        case .singleSelection:
            setupCircleView()
            squareView?.isHidden = true
        case .middleOfRangedSelection:
            setupSquareView()
            circleView?.isHidden = true
        case .startOfRangedSelection, .endOfRangedSelection:
            setupCircleView()
            setupSquareView()
        }

        setNeedsLayout()
    }

    private func setupCircleView() {
        if circleView == nil {
            circleView = DotView()
        }

        if let circleView = circleView {
            setupView(circleView)
            circleView.color = activeColor
        }
    }

    private func setupSquareView() {
        if squareView == nil {
            squareView = UIView()
        }

        if let squareView = squareView {
            setupView(squareView)
            squareView.backgroundColor = activeColor
        }
    }

    private func setupView(_ view: UIView) {
        if view.superview == nil {
            addSubview(view)
        }

        bringSubviewToFront(view)
        view.isHidden = !(selected || highlighted)
    }
}
