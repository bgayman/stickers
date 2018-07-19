//
//  MessagesViewController.swift
//  stickerPack
//
//  Created by B Gay on 7/19/18.
//  Copyright © 2018 B Gay. All rights reserved.
//

import UIKit
import Messages

class MessagesViewController: MSMessagesAppViewController {
    
    var browserViewController: StickerCollectionViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        browserViewController = StickerCollectionViewController()
        browserViewController.view.frame = view.frame
        browserViewController.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(browserViewController)
        view.addSubview(browserViewController.view)
        NSLayoutConstraint.activate([
            browserViewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            browserViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            browserViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            browserViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        browserViewController.didMove(toParent: self)
    }

}
