//
//  ParagraphViewController.swift
//  TLDR
//
//  Created by Anthony Yu on 9/1/15.
//  Copyright (c) 2015 Anthony Yu. All rights reserved.
//

import UIKit

class ParagraphViewController: UIViewController
{
    @IBOutlet weak var paragraph: UITextView! {
        didSet { paragraph.setNeedsDisplay() }
    }
    
    var url = ""
    
    func updateUI(content: NSString) {
        paragraph?.text = content as String
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadArticle()
    }
    
    func loadArticle() {
        let web = NSURL(string: url)
        var content:NSString = "" {
            didSet {
                updateUI(content)
            }
        }
        if web != nil {
            let task = NSURLSession.sharedSession().dataTaskWithURL(web!) {(data, response, error) in
                println(NSString(data: data, encoding: NSUTF8StringEncoding))
            }
            task.resume()
        }
        print("gg")
        File.save("~/Desktop/article.txt", content as String)
    }
}
