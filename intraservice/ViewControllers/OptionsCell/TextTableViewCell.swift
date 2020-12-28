//
//  TaskTextTableViewCell.swift
//  intraservice
//
//  Created by Cayenne on 10.12.2020.
//

import UIKit

class TextTableViewCell: UITableViewCell, UITextViewDelegate {
    
    
    @IBOutlet weak var textView: ZeroPaddingTextView!
    var textChanged: ((String) -> ())?
    @IBOutlet weak var titleLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textView.delegate = self
    }
    
    func textChanged(action: @escaping (String) -> Void) {
        textChanged = action
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textChanged?(textView.text)
    }
    
    func set(propertie: OptionKey, showLabel: Bool = true) {
        
        titleLabel.text = propertie.label
        if !showLabel || propertie.label.isEmpty {
            titleLabel.isHidden = true
        }
        
        textView.text = propertie.string
        textView.isScrollEnabled = false
        
    }
    
}


@IBDesignable class ZeroPaddingTextView: UITextView {

    override func layoutSubviews() {
        super.layoutSubviews()
        textContainerInset = UIEdgeInsets.zero
        textContainer.lineFragmentPadding = 0
    }
    
}
