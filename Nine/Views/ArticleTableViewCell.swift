//
//  ArticleTableViewCell.swift
//  Nine
//
//  Created by abc on 8/5/22.
//

import UIKit

class ArticleTableViewCell: UITableViewCell {
    
    static let identifier = "articleCell"
    static var nib = UINib(nibName: "ArticleTableViewCell", bundle: nil)
    
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var abstractLabel: UILabel!
    @IBOutlet weak var byLineLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureView(headline: String, abstract: String, byLine: String, image: UIImage?) {
        headlineLabel.text = headline
        abstractLabel.text = abstract
        byLineLabel.text = byLine
        thumbnailImageView.image = image
    }
    
}
