//
//  TriggerCollectionViewCell.swift
//  VideoPlayback
//
//  Created by Nicholas Naudé on 04/12/2016.
//  Copyright © 2016 Qualcomm. All rights reserved.
//

import UIKit

class TriggerCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var triggerImage: UIImageView!

override func prepareForReuse() {
            super.prepareForReuse()
            triggerImage.image = nil
        }
}
