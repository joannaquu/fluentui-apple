//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import FluentUI
import UIKit

class ButtonDemoController: DemoTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        readmeString = "A button triggers a single action or event.\n\nUse buttons for important actions like submitting a response, committing a change, or moving to the next step. If you need to navigate to another place, try a link instead."

        tableView.register(TableViewCell.self, forCellReuseIdentifier: TableViewCell.identifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: ButtonDemoController.cellReuseIdentifier)
    }

        for style in ButtonStyle.allCases {
            for size in ButtonSizeCategory.allCases {
                addTitle(text: style.description + ", " + size.description)

                let button = createButton(with: style,
                                          sizeCategory: size,
                                          title: "Text")
                let disabledButton = createButton(with: style,
                                                  sizeCategory: size,
                                                  title: "Text",
                                                  isEnabled: false)
                let titleButtonStack = UIStackView(arrangedSubviews: [button, disabledButton])
                titleButtonStack.spacing = 20
                titleButtonStack.distribution = .fillProportionally
                container.addArrangedSubview(titleButtonStack)

                if let image = size.image {
                    let iconButton = createButton(with: style,
                                                  sizeCategory: size,
                                                  title: "Text",
                                                  image: image)
                    let disabledIconButton = createButton(with: style,
                                                          sizeCategory: size,
                                                          title: "Text",
                                                          image: image,
                                                          isEnabled: false)
                    let titleImageButtonStack = UIStackView(arrangedSubviews: [iconButton, disabledIconButton])
                    titleImageButtonStack.spacing = 20
                    titleImageButtonStack.distribution = .fillProportionally
                    container.addArrangedSubview(titleImageButtonStack)

                    let iconOnlyButton = createButton(with: style,
                                                      sizeCategory: size,
                                                      image: image)
                    let disabledIconOnlyButton = createButton(with: style,
                                                              sizeCategory: size,
                                                              image: image,
                                                              isEnabled: false)
                    let imageButtonStack = UIStackView(arrangedSubviews: [iconOnlyButton, disabledIconOnlyButton])
                    imageButtonStack.spacing = 20
                    imageButtonStack.distribution = .fillProportionally
                    container.addArrangedSubview(imageButtonStack)
                }
            }
            cell.setup(title: "SwiftUI Demo")
            cell.accessoryType = .disclosureIndicator

            return cell

        case .textAndIcon,
             .textOnly,
             .iconOnly:
            let cell = tableView.dequeueReusableCell(withIdentifier: ButtonDemoController.cellReuseIdentifier, for: indexPath)
            let subviews = cell.contentView.subviews
            subviews.forEach { subview in
                subview.removeFromSuperview()
            }

            let image = row == .textOnly ? nil : section.image
            let text = row == .iconOnly ? nil : "Button"

            let button = dequeueDemoButton(indexPath: indexPath,
                                           style: section.buttonStyle,
                                           size: section.buttonSize,
                                           disabled: false)
            button.state.image = image
            button.state.text = text

            let disabledButton = dequeueDemoButton(indexPath: indexPath,
                                                   style: section.buttonStyle,
                                                   size: section.buttonSize,
                                                   disabled: true)
            disabledButton.state.image = image
            disabledButton.state.text = text

            let rowContentView = UIStackView(arrangedSubviews: [button, disabledButton])
            rowContentView.isLayoutMarginsRelativeArrangement = true
            rowContentView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 20)
            rowContentView.translatesAutoresizingMaskIntoConstraints = false
            rowContentView.alignment = .leading
            rowContentView.distribution = .fill
            rowContentView.spacing = 10

            cell.contentView.addSubview(rowContentView)
            NSLayoutConstraint.activate([
                cell.contentView.leadingAnchor.constraint(equalTo: rowContentView.leadingAnchor),
                cell.contentView.topAnchor.constraint(equalTo: rowContentView.topAnchor),
                cell.contentView.bottomAnchor.constraint(equalTo: rowContentView.bottomAnchor)
            ])

            return cell
        }

        addTitle(text: "With multi-line title")
        let button = createButton(with: .accent,
                                  title: "Longer Text Button")
        let iconButton = createButton(with: .accent,
                                      title: "Longer Text Button",
                                      image: ButtonSizeCategory.large.image)
        addRow(items: [button])
        addRow(items: [iconButton])

        container.addArrangedSubview(UIView())

        let customButton = createButton(with: .accent, sizeCategory: .small, title: "ToolBar Test Button")
        let buttonBarItem = UIBarButtonItem.init(customView: customButton)
        customButton.sizeToFit()
        toolbarItems = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            buttonBarItem,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        ]
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.isToolbarHidden = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isToolbarHidden = true
    }

    private func createButton(with style: ButtonStyle, sizeCategory: ButtonSizeCategory = .large, title: String? = nil, image: UIImage? = nil, isEnabled: Bool = true) -> Button {
        let button = Button(style: style)
        button.sizeCategory = sizeCategory
        if let title = title {
            button.setTitle(title, for: .normal)
            button.titleLabel?.numberOfLines = 0
        }
        if let image = image {
            button.image = image
        }
        button.isEnabled = isEnabled
        button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        buttons.append(button)
        return button
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return ButtonDemoSection.allCases[indexPath.section].rows[indexPath.row] == .swiftUIDemo
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }

        cell.setSelected(false, animated: true)

        switch ButtonDemoSection.allCases[indexPath.section].rows[indexPath.row] {
        case .swiftUIDemo:
            navigationController?.pushViewController(ButtonDemoControllerSwiftUI(),
                                                     animated: true)
        default:
            break
        }
    }

    // MARK: - Private helpers

    private static let cellReuseIdentifier: String = "cellReuseIdentifier"

    private var buttons: [String: MSFButton] = [:]

    private func dequeueDemoButton(indexPath: IndexPath,
                                   style: MSFButtonStyle,
                                   size: MSFButtonSize,
                                   disabled: Bool) -> MSFButton {
        let key = "\(indexPath)-\(disabled)"
        if let button = buttons[key] {
            return button
        } else {
            let button = MSFButton(style: style,
                                   size: size) { _ in
                self.didPressButton()
            }
            button.state.isDisabled = disabled
            buttons[key] = button

            return button
        }
    }

    private func didPressButton() {
        let alert = UIAlertController(title: "A button was pressed",
                                      message: nil,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        present(alert, animated: true)
    }

    private enum ButtonDemoSection: CaseIterable {
        case swiftUI
        case primarySmall
        case primaryMedium
        case primaryLarge
        case secondarySmall
        case secondaryMedium
        case secondaryLarge
        case ghostSmall
        case ghostMedium
        case ghostLarge
        case accentFloatingSmall
        case accentFloatingLarge
        case subtleFloatingSmall
        case subtleFloatingLarge

        var buttonSize: MSFButtonSize {
            switch self {
            case .primarySmall,
                 .secondarySmall,
                 .ghostSmall,
                 .accentFloatingSmall,
                 .subtleFloatingSmall:
                return .small
            case .primaryMedium,
                 .secondaryMedium,
                 .ghostMedium:
                return .medium
            case .primaryLarge,
                 .secondaryLarge,
                 .ghostLarge,
                 .accentFloatingLarge,
                 .subtleFloatingLarge:
                return .large
            case .swiftUI:
                preconditionFailure("SwiftUI row should not display a Button")
            }
        }

extension ButtonSizeCategory {
    var description: String {
        switch self {
        case .large:
            return "large"
        case .medium:
            return "medium"
        case .small:
            return "small"
        }
    }

    private enum ButtonDemoRow: CaseIterable {
        case swiftUIDemo
        case textAndIcon
        case textOnly
        case iconOnly

        var isDemoRow: Bool {
            switch self {
            case .textAndIcon,
                 .textOnly,
                 .iconOnly:
                return true
            case .swiftUIDemo:
                return false
            }
        }
    }
}

extension ButtonDemoController: DemoAppearanceDelegate {
    func themeWideOverrideDidChange(isOverrideEnabled: Bool) {
        guard let fluentTheme = self.view.window?.fluentTheme else {
            return
        }

        fluentTheme.register(tokenSetType: ButtonTokenSet.self, tokenSet: isOverrideEnabled ? themeWideOverrideButtonTokens : nil)
    }

    func perControlOverrideDidChange(isOverrideEnabled: Bool) {
        self.buttons.forEach({ (_: String, button: MSFButton) in
            button.tokenSet.replaceAllOverrides(with: isOverrideEnabled ? perControlOverrideButtonTokens : nil)
        })
    }

    func isThemeWideOverrideApplied() -> Bool {
        return self.view.window?.fluentTheme.tokens(for: ButtonTokenSet.self)?.isEmpty == false
    }

    // MARK: - Custom tokens

    private var themeWideOverrideButtonTokens: [ButtonTokenSet.Tokens: ControlTokenValue] {
        return [
            .textFont: .fontInfo { FontInfo(name: "Times", size: 20.0, weight: .regular) }
        ]
    }

    private var perControlOverrideButtonTokens: [ButtonTokenSet.Tokens: ControlTokenValue] {
        return [
            .textFont: .fontInfo { FontInfo(name: "Papyrus", size: 20.0, weight: .regular) }
        ]
    }
}
