//
//  QueenlyViewController.swift
//  QueenlyTryOn
//
//  Created by Mica Morales on 4/1/24.
//

import UIKit

public class QueenlyViewController: UIViewController {
    
    let imageHandler = QImageHandler()
    let key = QKey()
    
    let headerHeight: CGFloat = 68
    
    let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    var contentBounds: CGRect {
        return CGRect(x: 0, y: headerHeight, width: view.bounds.size.width, height: view.bounds.size.height - headerHeight)
    }
    
    lazy var headerView: QNavigationHeaderView = {
        let headerView = QNavigationHeaderView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.delegate = self
        headerView.isUserInteractionEnabled = true
        return headerView
    }()
    
    lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }()
    
    let loadingOverlayView = QLoadingOverlayView()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        isModalInPresentation = true
        layout()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        if let navVC = navigationController, navVC.visibleViewController != navVC.viewControllers.first {
            headerView.buttonStyle = .back
        }
    }
    
    private func layout() {
        view.addSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.heightAnchor.constraint(equalToConstant: headerHeight),
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        view.insertSubview(contentView, belowSubview: headerView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    func renderSpinner() {
        loadingOverlayView.render(on: view, belowSubview: headerView)
    }
    
    func removeSpinner() {
        loadingOverlayView.removeFromSuperview()
    }
    
    func renderAlertPopUp(title: String = "",
                          message: String = "",
                          type: QAlertType,
                          duration: CGFloat = 1.25,
                          shouldDismiss: Bool = false) {
        let alert = QAlertPopUp(title: title, message: message, type: type, duration: duration) { [weak self] in
            if shouldDismiss {
                self?.dismiss(animated: true)
            }
        }
        present(alert, animated: true)
    }
    
    func didTapOnBack() {
        if let navVC = navigationController, navVC.visibleViewController != navVC.viewControllers.first {
            navVC.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}

// MARK: - QueenlyNavigationHeaderViewDelegate
extension QueenlyViewController: QueenlyNavigationHeaderViewDelegate {
    func onBackButton(in headerView: QNavigationHeaderView) {
        didTapOnBack()
    }
}
