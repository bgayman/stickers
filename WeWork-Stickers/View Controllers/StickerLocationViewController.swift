//
//  StickerLocationViewController.swift
//  WeWork-Stickers
//
//  Created by brad.gayman on 7/18/18.
//  Copyright © 2018 B Gay. All rights reserved.
//

import UIKit
import MapKit

// MARK: - StickerLocationViewController -
final class StickerLocationViewController: UIViewController {

    // MARK: - Properties -
    let sticker: Sticker
    lazy var annotation: StickerAnnotation = {
        let annotation = StickerAnnotation(sticker: self.sticker)
        return annotation
    }()
    lazy var doneButton: UIBarButtonItem = {
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didPressDone(_:)))
        return doneButton
    }()

    // MARK: - Init -
    init(sticker: Sticker) {
        self.sticker = sticker
        super.init(nibName: "\(StickerLocationViewController.self)", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Outlets -
    @IBOutlet weak var mapView: MKMapView!

    // MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - Private Methods -
    private func setupUI() {
        mapView.addAnnotation(annotation)
        mapView.setCenter(annotation.coordinate, animated: false)
        if UIApplication.shared.keyWindow?.rootViewController?.traitCollection.horizontalSizeClass == .regular, UIApplication.shared.keyWindow?.rootViewController?.traitCollection.verticalSizeClass == .regular {
            navigationController?.setNavigationBarHidden(true, animated: false)
        } else {
            title = sticker.title
            navigationController?.navigationBar.isTranslucent = true
            navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationController?.navigationBar.shadowImage = UIImage()
            navigationController?.navigationBar.tintColor = UIColor.appRed
            navigationItem.rightBarButtonItem = doneButton
        }
    }

    // MARK: - Actions -
    @objc
    private func didPressDone(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}

extension StickerLocationViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
        annotationView.tintColor = UIColor.appRed
        annotationView.glyphImage = UIImage(named: "icStickerSelected")!
        return annotationView
    }
}
