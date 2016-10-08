//
//  DefaultSoundTableViewCell.swift
//  AlarmCharm
//
//  Created by Laura Brouckman and Alexander Carlisle on 5/22/16.
//  Copyright © 2016 Brarlisle. All rights reserved.
//
// Alexander Carlisle

import UIKit

class DefaultSoundTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    var delegate : DefaultSoundTableViewCellDelegate?

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var setButton: UIButton!
    
    //Make buttons bigger, make sure when song is set the cell is highlighted and NS user preferences get set
    @IBAction func Play(_ sender: UIButton) {
        delegate?.cellWasPressed(self, button: sender)
    }
    @IBAction func Stop(_ sender: UIButton) {
        delegate?.cellWasPressed(self, button: sender)
    }
    @IBAction func Set(_ sender: UIButton) {
        delegate?.cellWasPressed(self, button: sender)
    }
    @IBOutlet weak var SongNameLabel: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
