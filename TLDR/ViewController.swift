//
//  ViewController.swift
//  TLDR
//
//  Created by Anthony Yu on 9/1/15.
//  Copyright (c) 2015 Anthony Yu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var webUrl: UITextField!
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let pvc = segue.destinationViewController as? ParagraphViewController {
            if segue.identifier == "read article" {
                pvc.url = webUrl.text
            }
        }
    }

} 

