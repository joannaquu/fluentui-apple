//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import FluentUI
import UIKit

class CommandBarDemoController: DemoController {
    enum Command {
        case add
        case mention
        case calendar

        case textBold
        case textItalic
        case textUnderline
        case textStrikethrough

        case arrowUndo
        case arrowRedo

        case copy
        case delete

        case checklist
        case bulletList
        case numberList
        case link

        case keyboard

        case textStyle

        case customView

        case disabledText

        var iconImage: UIImage? {
            switch self {
            case .add:
                return UIImage(named: "add24Regular")
            case .mention:
                return UIImage(named: "mention24Regular")
            case .calendar:
                return UIImage(named: "calendar24Regular")
            case .textBold:
                return UIImage(named: "textBold24Regular")
            case .textItalic:
                return UIImage(named: "textItalic24Regular")
            case .textUnderline:
                return UIImage(named: "textUnderline24Regular")
            case .textStrikethrough:
                return UIImage(named: "textStrikethrough24Regular")
            case .arrowUndo:
                return UIImage(named: "arrowUndo24Regular")
            case .arrowRedo:
                return UIImage(named: "arrowRedo24Filled")
            case .copy:
                return UIImage(named: "copy24Regular")
            case .delete:
                return UIImage(named: "delete24Regular")
            case .checklist:
                return UIImage(named: "textChecklistListLtr24Regular")
            case .bulletList:
                return UIImage(named: "textBulletList24Regular")
            case .numberList:
                return UIImage(named: "textNumberListLtr24Regular")
            case .link:
                return UIImage(named: "link24Regular")
            case .keyboard:
                return UIImage(named: "keyboardDock24Regular")
            case .textStyle, .disabledText, .customView:
                return nil
            }
        }

        var accentImage: UIImage? {
            switch self {
            case .delete:
                return UIImage(named: "delete24Filled")
            case .add, .mention, .calendar, .textBold, .textItalic, .textUnderline, .textStrikethrough, .arrowUndo,
                    .arrowRedo, .copy, .checklist, .bulletList, .numberList, .link, .keyboard, .textStyle, .customView, .disabledText:
                return nil
            }
        }

        var title: String? {
            switch self {
            case .textStyle:
                return TextStyle.body.textRepresentation
            case .disabledText:
                return "Search"
            case .add:
                return "Add"
            case .delete, .mention, .calendar, .textBold, .textItalic, .textUnderline, .textStrikethrough, .arrowUndo,
                    .arrowRedo, .copy, .checklist, .bulletList, .numberList, .link, .keyboard, .customView:
                return nil
            }
        }

        var titleFont: UIFont? {
            switch self {
            case .textStyle:
                return TextStyle.body.font
            case .disabledText:
                return .systemFont(ofSize: 15, weight: .regular)
            case .add, .mention, .calendar, .textBold, .textItalic, .textUnderline, .textStrikethrough, .arrowUndo,
                    .arrowRedo, .copy, .checklist, .bulletList, .numberList, .link, .keyboard, .delete, .customView:
                return nil
            }
        }

        var isPersistSelection: Bool {
            switch self {
            case .add, .mention, .calendar, .arrowUndo, .arrowRedo, .copy, .delete, .link, .keyboard, .textStyle, .disabledText, .customView:
                return false
            case .textBold, .textItalic, .textUnderline, .textStrikethrough, .checklist, .bulletList, .numberList:
                return true
            }
        }
    }

    enum TextStyle: String {
        case body
        case subhead
        case title

        var textRepresentation: String {
            rawValue.capitalized
        }

        var font: UIFont {
            switch self {
            case .body:
                return .systemFont(ofSize: 15, weight: .regular)
            case .subhead:
                return .systemFont(ofSize: 15, weight: .bold)
            case .title:
                return .systemFont(ofSize: 20, weight: .bold)
            }
        }

        static func next(for textRepresentation: String?) -> TextStyle {
            guard let rawValue = textRepresentation?.lowercased(), let textStyle = TextStyle(rawValue: rawValue) else {
                return .body
            }

            switch textStyle {
            case .body:
                return .title
            case .subhead:
                return .body
            case .title:
                return .subhead
            }
        }
    }

    var defaultCommandBar: CommandBar?
    var animateCommandBarDelegateEvents: Bool = false

    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = UIColor(dynamicColor: view.fluentTheme.aliasTokens.colors[.background3])
        textField.placeholder = "Text Field"

        return textField
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        readmeString = "The contextual command bar appears above the keyboard to provide contextual actions relevant to the content within the current view, like text formatting in Word."

        container.layoutMargins.right = 0
        container.layoutMargins.left = 0
        view.backgroundColor = UIColor(dynamicColor: view.fluentTheme.aliasTokens.colors[.background4])

        container.addArrangedSubview(createLabelWithText("Default"))

        let commandBar = CommandBar(itemGroups: createItemGroups(), leadingItemGroups: [[newItem(for: .keyboard)]])
        commandBar.delegate = self
        commandBar.translatesAutoresizingMaskIntoConstraints = false
        commandBar.backgroundColor = UIColor(dynamicColor: view.fluentTheme.aliasTokens.colors[.background3])
        container.addArrangedSubview(commandBar)
        defaultCommandBar = commandBar

        let itemCustomizationContainer = UIStackView()
        itemCustomizationContainer.spacing = CommandBarDemoController.verticalStackViewSpacing
        itemCustomizationContainer.axis = .vertical
        itemCustomizationContainer.backgroundColor = UIColor(dynamicColor: view.fluentTheme.aliasTokens.colors[.background3])

        itemCustomizationContainer.addArrangedSubview(UIView()) //Spacer

        let refreshButton = MSFButton(style: .secondary,
                                      size: .small) { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.refreshDefaultBarItems()
        }
        refreshButton.state.text = "Refresh 'Default' Bar"
        itemCustomizationContainer.addArrangedSubview(refreshButton)

        let removeTrailingItemButton = MSFButton(style: .secondary,
                                                 size: .small) { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.removeDefaultTrailingBarItems()
        }
        removeTrailingItemButton.state.text = "Remove Trailing Button"
        itemCustomizationContainer.addArrangedSubview(removeTrailingItemButton)

        let refreshTrailingItemButton = MSFButton(style: .secondary,
                                                  size: .small) { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.refreshDefaultTrailingBarItems()
        }
        refreshTrailingItemButton.state.text = "Refresh Trailing Button"
        itemCustomizationContainer.addArrangedSubview(refreshTrailingItemButton)

        let removeLeadingItemButton = MSFButton(style: .secondary,
                                                size: .small) { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.removeDefaultLeadingBarItems()
        }
        removeLeadingItemButton.state.text = "Remove Leading Button"
        itemCustomizationContainer.addArrangedSubview(removeLeadingItemButton)

        let refreshLeadingItemButton = MSFButton(style: .secondary,
                                                 size: .small) { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.refreshDefaultLeadingBarItems()
        }
        refreshLeadingItemButton.state.text = "Refresh Leading Button"
        itemCustomizationContainer.addArrangedSubview(refreshLeadingItemButton)

        let resetScrollPositionButton = MSFButtonLegacy(style: .tertiaryOutline)
        resetScrollPositionButton.setTitle("Reset Scroll Position", for: .normal)
        resetScrollPositionButton.addTarget(self, action: #selector(resetScrollPosition), for: .touchUpInside)
        itemCustomizationContainer.addArrangedSubview(resetScrollPositionButton)

        let deleteAccentImageStackView = createHorizontalStackView()
        deleteAccentImageStackView.addArrangedSubview(createLabelWithText("\"Delete\" Accent Image"))
        let deleteAccentImageSwitch: UISwitch = UISwitch()
        deleteAccentImageSwitch.isOn = true
        deleteAccentImageSwitch.addTarget(self, action: #selector(deleteAccentImageValueChange), for: .valueChanged)
        deleteAccentImageStackView.addArrangedSubview(deleteAccentImageSwitch)
        itemCustomizationContainer.addArrangedSubview(deleteAccentImageStackView)

        let itemEnabledStackView = createHorizontalStackView()
        itemEnabledStackView.addArrangedSubview(createLabelWithText("'+' Enabled"))
        let itemEnabledSwitch: UISwitch = UISwitch()
        itemEnabledSwitch.isOn = true
        itemEnabledSwitch.addTarget(self, action: #selector(itemEnabledValueChanged), for: .valueChanged)
        itemEnabledStackView.addArrangedSubview(itemEnabledSwitch)
        itemCustomizationContainer.addArrangedSubview(itemEnabledStackView)

        let itemHiddenStackView = createHorizontalStackView()
        itemHiddenStackView.addArrangedSubview(createLabelWithText("'Delete' Hidden"))
        let itemHiddenSwitch: UISwitch = UISwitch()
        itemHiddenSwitch.isOn = false
        itemHiddenSwitch.addTarget(self, action: #selector(itemHiddenValueChanged), for: .valueChanged)
        itemHiddenStackView.addArrangedSubview(itemHiddenSwitch)
        itemCustomizationContainer.addArrangedSubview(itemHiddenStackView)

        let commandBarDelegateEventAnimationView = createHorizontalStackView()
        commandBarDelegateEventAnimationView.addArrangedSubview(createLabelWithText("Animate CommandBarDelegate Events"))
        let commandBarDelegateEventAnimationSwitch: UISwitch = UISwitch()
        commandBarDelegateEventAnimationSwitch.isOn = animateCommandBarDelegateEvents
        commandBarDelegateEventAnimationSwitch.addTarget(self, action: #selector(animateCommandBarDelegateEventsValueChanged), for: .valueChanged)
        commandBarDelegateEventAnimationView.addArrangedSubview(commandBarDelegateEventAnimationSwitch)
        itemCustomizationContainer.addArrangedSubview(commandBarDelegateEventAnimationView)

        itemCustomizationContainer.addArrangedSubview(UIView()) //Spacer

        container.addArrangedSubview(itemCustomizationContainer)

        container.addArrangedSubview(createLabelWithText("With Fixed Button"))

        let fixedButtonCommandBar = CommandBar(itemGroups: createItemGroups(), leadingItemGroups: [[newItem(for: .copy)]], trailingItemGroups: [[newItem(for: .keyboard)]])
        fixedButtonCommandBar.translatesAutoresizingMaskIntoConstraints = false
        fixedButtonCommandBar.backgroundColor = UIColor(dynamicColor: view.fluentTheme.aliasTokens.colors[.background3])
        container.addArrangedSubview(fixedButtonCommandBar)

        container.addArrangedSubview(createLabelWithText("In Input Accessory View"))

        let textFieldContainer = UIView()
        textFieldContainer.backgroundColor = UIColor(dynamicColor: view.fluentTheme.aliasTokens.colors[.background3])
        textFieldContainer.addSubview(textField)
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: textFieldContainer.topAnchor, constant: 16.0),
            textField.leadingAnchor.constraint(equalTo: textFieldContainer.leadingAnchor, constant: 16.0),
            textFieldContainer.bottomAnchor.constraint(equalTo: textField.bottomAnchor, constant: 16.0),
            textFieldContainer.trailingAnchor.constraint(equalTo: textField.trailingAnchor, constant: 16.0)
        ])

        container.addArrangedSubview(textFieldContainer)

        let accessoryCommandBar = CommandBar(itemGroups: createItemGroups(), trailingItemGroups: [[newItem(for: .keyboard)]])
        accessoryCommandBar.translatesAutoresizingMaskIntoConstraints = false
        textField.inputAccessoryView = accessoryCommandBar
    }

    func createItemGroups() -> [CommandBarItemGroup] {
        let commandGroups: [[Command]] = [
            [
                .add,
                .mention,
                .calendar
            ],
            [
                .textStyle
            ],
            [
                .disabledText
            ],
            [
                .textBold,
                .textItalic,
                .textUnderline,
                .textStrikethrough
            ],
            [
                .arrowUndo,
                .arrowRedo
            ],
            [
                .delete
            ],
            [
                .checklist,
                .bulletList,
                .numberList,
                .link
            ],
            [
                .customView
            ]
        ]

        let itemGroups: [CommandBarItemGroup] = commandGroups.map { commandGroup in
            commandGroup.map { command in
                newItem(for: command)
            }
        }

        itemGroups[0][1].isEnabled = false
        itemGroups[2][0].isEnabled = false

        // Copy item
        let copyItem = itemGroups[4][0]
        copyItem.menu = UIMenu(children: [UIAction(title: "Copy Image", image: UIImage(named: "copy24Regular"), handler: { _ in }),
                                          UIAction(title: "Copy Text", image: UIImage(named: "text24Regular"), handler: { _ in })])
        copyItem.showsMenuAsPrimaryAction = true

        return itemGroups
    }

    func createLabelWithText(_ text: String = "") -> Label {
        let label = Label()
        label.text = text
        label.textAlignment = .center
        return label
    }

    func newItem(for command: Command, isEnabled: Bool = true, isSelected: Bool = false) -> CommandBarItem {
        let commandBarItem = CommandBarItem(
            iconImage: command.iconImage,
            title: command.title,
            titleFont: command.titleFont,
            isEnabled: isEnabled,
            isSelected: isSelected,
            itemTappedHandler: { [weak self] (_, item) in
                self?.handleCommandItemTapped(command: command, item: item)
            },
            accessibilityHint: "sample accessibility hint"
        )

        commandBarItem.accentImage = command.accentImage
        commandBarItem.accentImageTintColor = UIColor(dynamicColor: view.fluentTheme.aliasTokens.colors[.brandForeground1])

        if command == .customView {
            commandBarItem.customControlView = { () -> UIView in
                let label = self.createLabelWithText("Custom View")
                label.translatesAutoresizingMaskIntoConstraints = false
                return label
            }
        }

        return commandBarItem
    }

    func handleCommandItemTapped(command: Command, item: CommandBarItem) {
        if command.isPersistSelection {
            item.isSelected.toggle()
        }

        let isSelected = item.isSelected || !command.isPersistSelection

        switch command {
        case .keyboard:
            textField.resignFirstResponder()
        case .textStyle:
            let textStyle = TextStyle.next(for: item.title)
            item.title = textStyle.textRepresentation
            item.titleFont = textStyle.font
        default:
            let alert = UIAlertController(title: "Did \(isSelected ? "select" : "deselect") command \(command)", message: nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default)
            alert.addAction(action)
            present(alert, animated: true)
        }
    }

    func createHorizontalStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.spacing = CommandBarDemoController.horizontalStackViewSpacing
        return stackView
    }

    @objc func itemEnabledValueChanged(sender: UISwitch!) {
        guard let item: CommandBarItem = defaultCommandBar?.itemGroups[0][0] else {
            return
        }

        item.isEnabled = sender.isOn
    }

    @objc func itemHiddenValueChanged(sender: UISwitch!) {
        guard let item: CommandBarItem = defaultCommandBar?.itemGroups[5][0] else {
            return
        }

        item.isHidden = sender.isOn
    }

    @objc func deleteAccentImageValueChange(sender: UISwitch!) {
        guard let item: CommandBarItem = defaultCommandBar?.itemGroups[5][0] else {
            return
        }

        if sender.isOn {
            item.accentImage = Command.delete.accentImage
        } else {
            item.accentImage = nil
        }
    }

    @objc func animateCommandBarDelegateEventsValueChanged(sender: UISwitch!) {
        animateCommandBarDelegateEvents = sender.isOn
    }

    @objc func refreshDefaultBarItems() {
        defaultCommandBar?.itemGroups = createItemGroups()
    }

    @objc func removeDefaultTrailingBarItems() {
        defaultCommandBar?.trailingItemGroups = []
    }

    @objc func refreshDefaultTrailingBarItems() {
        defaultCommandBar?.trailingItemGroups = [[newItem(for: .keyboard)]]
    }

    @objc func removeDefaultLeadingBarItems() {
        defaultCommandBar?.leadingItemGroups = []
    }

    @objc func refreshDefaultLeadingBarItems() {
        defaultCommandBar?.leadingItemGroups = [[newItem(for: .keyboard)]]
    }

    @objc func resetScrollPosition(sender: UIButton!) {
        defaultCommandBar?.resetScrollPosition(true)
    }

    private static let horizontalStackViewSpacing: CGFloat = 16.0
    private static let verticalStackViewSpacing: CGFloat = 8.0
}

extension CommandBarDemoController: DemoAppearanceDelegate {
    func themeWideOverrideDidChange(isOverrideEnabled: Bool) {
        guard let fluentTheme = self.view.window?.fluentTheme else {
            return
        }
        fluentTheme.register(tokenSetType: CommandBarTokenSet.self,
                             tokenSet: isOverrideEnabled ? themeWideOverrideCommandBarTokens : nil)
    }

    func perControlOverrideDidChange(isOverrideEnabled: Bool) {
        defaultCommandBar?.tokenSet.replaceAllOverrides(with: isOverrideEnabled ? perControlOverrideCommandBarTokens : nil)
    }

    func isThemeWideOverrideApplied() -> Bool {
        return self.view.window?.fluentTheme.tokens(for: CommandBarTokenSet.self)?.isEmpty == false
    }

    // MARK: - Custom tokens

    private var themeWideOverrideCommandBarTokens: [CommandBarTokenSet.Tokens: ControlTokenValue] {
        return [
            .itemBackgroundColorRest: .dynamicColor { DynamicColor(light: GlobalTokens.sharedColors(.red, .primary)) }
        ]
    }

    private var perControlOverrideCommandBarTokens: [CommandBarTokenSet.Tokens: ControlTokenValue] {
        return [
            .itemBackgroundColorRest: .dynamicColor { DynamicColor(light: GlobalTokens.sharedColors(.grape, .primary)) }
        ]
    }
}

extension CommandBarDemoController: CommandBarDelegate {
    func commandBarDidScroll(_ commandBar: CommandBar) {
        if animateCommandBarDelegateEvents {
            let originalBackgroundColor = commandBar.backgroundColor

            UIView.animate(withDuration: 1.0, delay: 0.0, options: [.allowUserInteraction]) {
                commandBar.backgroundColor = UIColor(dynamicColor: self.view.fluentTheme.aliasTokens.colors[.brandBackground1])
            } completion: { _ in
                commandBar.backgroundColor = originalBackgroundColor
            }
        }
    }
}
