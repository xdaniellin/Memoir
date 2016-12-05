//
//  VideoCollectionViewCell.swift
//  VideoPlayback
//
//  Created by Nicholas Naudé on 04/12/2016.
//  Copyright © 2016 Qualcomm. All rights reserved.
//

import UIKit

class VideoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var videoImage: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        videoImage.image = nil
    }
}
