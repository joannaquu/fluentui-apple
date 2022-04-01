//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import FluentUI
import UIKit

class HUDDemoController: DemoController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let showActivityButton = MSFButton(style: .secondary, size: .small, action: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }

            strongSelf.showActivityHUD()
        })
        showActivityButton.state.text = "Show activity HUD"
        container.addArrangedSubview(showActivityButton)

        let showSuccessButton = MSFButton(style: .secondary, size: .small, action: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }

            strongSelf.showSuccessHUD()
        })
        showSuccessButton.state.text = "Show success HUD"
        container.addArrangedSubview(showSuccessButton)

        let showFailureButton = MSFButton(style: .secondary, size: .small, action: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }

            strongSelf.showFailureHUD()
        })
        showFailureButton.state.text = "Show failure HUD"
        container.addArrangedSubview(showFailureButton)

        let showCustomButton = MSFButton(style: .secondary, size: .small, action: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }

            strongSelf.showCustomHUD()
        })
        showCustomButton.state.text = "Show custom HUD"
        container.addArrangedSubview(showCustomButton)

        let showCustomNonBlockingButton = MSFButton(style: .secondary, size: .small, action: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }

            strongSelf.showCustomNonBlockingHUD()
        })
        showCustomNonBlockingButton.state.text = "Show custom non-blocking HUD"
        container.addArrangedSubview(showCustomNonBlockingButton)

        let showNolabelButton = MSFButton(style: .secondary, size: .small, action: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }

            strongSelf.showNoLabelHUD()
        })
        showNolabelButton.state.text = "Show HUD with no label"
        container.addArrangedSubview(showNolabelButton)

        let showGestureButton = MSFButton(style: .secondary, size: .small, action: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }

            strongSelf.showGestureHUD()
        })
        showGestureButton.state.text = "Show HUD with tap gesture callback"
        container.addArrangedSubview(showGestureButton)

        let showUpdatingButton = MSFButton(style: .secondary, size: .small, action: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }

            strongSelf.showUpdateHUD()
        })
        showUpdatingButton.state.text = "Show HUD with updating caption"
        container.addArrangedSubview(showUpdatingButton)
    }

    @objc private func showActivityHUD() {
        HUD.shared.show(in: view, with: HUDParams(caption: "Loading for 3 seconds"))
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            HUD.shared.hide()
        }
    }

    @objc private func showSuccessHUD() {
        HUD.shared.showSuccess(from: self, with: "Success")
    }

    @objc private func showFailureHUD() {
        HUD.shared.showFailure(from: self, with: "Failure")
    }

    @objc private func showCustomHUD() {
        HUD.shared.show(in: self.view, with: HUDParams(caption: "Custom", image: UIImage(named: "flag-40x40"), isPersistent: false))
    }

    @objc private func showCustomNonBlockingHUD() {
        HUD.shared.show(in: view, with: HUDParams(caption: "Custom image non-blocking", image: UIImage(named: "flag-40x40"), isBlocking: false))
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            HUD.shared.hide()
        }
    }

    @objc private func showNoLabelHUD() {
        HUD.shared.show(in: view)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            HUD.shared.hide()
        }
    }

    @objc private func showGestureHUD() {
        HUD.shared.show(in: view, with: HUDParams(caption: "Downloading..."), onTap: {
            self.showMessage("Stop Download?", autoDismiss: false) {
                HUD.shared.hide()
            }
        })
    }

    @objc private func showUpdateHUD() {
        HUD.shared.show(in: view, with: HUDParams(caption: "Downloading..."))
        var time: TimeInterval = 0
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            time += timer.timeInterval
            if time < 4 {
                HUD.shared.update(with: "Downloading \(Int(time))")
            } else {
                timer.invalidate()
                HUD.shared.update(with: "Download complete!")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    HUD.shared.hide()
                }
            }
        }
    }
}
