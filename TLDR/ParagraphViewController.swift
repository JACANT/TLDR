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

    
    func updateUI(content :String) {
//        print(content)
        print(getArticle(content))
        dispatch_async(dispatch_get_main_queue(), { //UI stuff must be run on main thread, must be sequencial
            self.paragraph.text = self.getArticle(content)
        });
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let test1 = "<gg> if this is print then fuck </gg>this is bad <p>hi im awesome\n how are you?<a bcdefg> I am fine. </a> so what is up guys?</p>Please don't print me either\n"
        
        
//        let test2 = "<p class=\"text  small-offset-3 \"><span class=\"referenced-item-excerpt hide-for-small\">Some people have called anxiety the Disease of the 21st Century; and on an anecdotal level,…</span><a href=\"http://io9.com/are-we-in-the-midst-of-an-anxiety-epidemic-1459542453\" class=\"js_readmore readmore-referenced\" onclick=\"window.ga('send', 'event', 'Permalink page click', 'Permalink page click - inset read more link');\" target=\"_blank\">Read more <span class=\"js_external-text hide\">Read more</span></a></p>"
        
//        let test3 = "<ul class=\"show-for-medium-down\"><li class=\"js_follow-controls js_follow-blog-controls follow-controls--blog-menu\" data-blogid=\"8\"><a href=\"#\" class=\"js_followblogforuser button list-entity__button--follow list-control follow-state following list-control--active hide\"><span>Follow io9</span><svg class=\"svg-icon small svg-add--small\"><use xlink:href=\"#iconset-add--small\" /></svg></a><a href=\"#\" class=\"js_unfollowblogforuser button list-entity__button--following list-control follow-state following list-control--active hide\"><span>Following io9</span><svg class=\"svg-icon small svg-checkmark--small\"><use xlink:href=\"#iconset-checkmark--small\" /></svg></a></li></ul>"

//        print(test3)
//        let answer = getArticle(test3)
//        print(answer)
        loadArticle()
    }
    
    
    func loadArticle() {
        let web = NSURL(string: url)
        if web != nil {
            let task = NSURLSession.sharedSession().dataTaskWithURL(web!)
                {(myData, response, error) in
                    if (error == nil) {
                        let myWebString = NSString(data: myData!, encoding: NSUTF8StringEncoding)
                        self.updateUI(myWebString as! String)
                    }
                }
            task.resume()
        }
    }
    
/*
    return true if sentence contains NSCharacterSet
*/
    
    func containsLetters(sentence: String) -> Bool {
        let letters = NSCharacterSet.letterCharacterSet()
        return sentence.rangeOfCharacterFromSet(letters) != nil
    }
/*
    parse out all sentences within one html block
    example:
        <p>
          ↑
        idxIn
            <a>abc</a>
            <a>de <small>f</small></a>
            <span>
                <img ../><a>uck</a>
            </span>
        </p>
           ↑
        idxOut
    
    returns: sentence: abcde fuck
             idx: idx of the last >
*/
    func extractSentenceFromBlock(webString: String, var idx: String.Index) -> (sentence: String, idx: String.Index) {
//        print("inside extract at \(webString[idx])\n")
        var sentence = String()
        var cur: Character
        var inBlock = false
        let endBlockChar: Character = "/"
        let BlockChar: Character = "<"
        idx = idx.successor()
        
        while true {
            cur = webString[idx]
            if (cur == BlockChar) {
                inBlock = true
            }else if inBlock {
                if (cur == endBlockChar) {
                    idx = advanceToEndOfBlock(webString, idx: idx).endIdx
//                    print("partial sentence is: \(sentence)")
                    return (sentence, idx)
                } else {
                    let blockInfo = advanceToEndOfBlock(webString, idx: idx)
                    if (blockInfo.selfContained) {
                        idx = blockInfo.endIdx
                    } else {
                        let subSentence = extractSentenceFromBlock(webString, idx: blockInfo.endIdx)
                        sentence += subSentence.sentence
                        idx = subSentence.idx
                    }
                }
                inBlock = false
            } else {
                sentence.append(cur)
            }
            idx = idx.successor()
        }
        
    }
    
    
/*
 * .... <x........> .....
 *       ↑        ↑
 *     idxIn   idxOut
 * selfContained is true if the block looks like <...../>, false otherwise
*/
    func advanceToEndOfBlock(webString: String, var idx: String.Index) -> (endIdx: String.Index, selfContained: Bool) {
//        print("inside advanceToEndOfBlock at \(webString[idx])\n")
        var selfContained = false
        if (webString[idx] == "!") {
            selfContained = true
        }
        while (webString[idx] != ">") {
            idx = idx.successor()
        }
        if (webString[idx.predecessor()] == "/") {
            selfContained = true
        }
//        print("return advanceToEndOfBlock at \(webString[idx.successor()])")
        return (idx, selfContained)
    }
    
/*
    return trur if block if useful.
    Usefullness is defined as blocks that might potentially contain parts of article that needs to be retreived
*/
    func isUsefulBlock(first: Character, second: Character) -> Bool {
        let PotentiallyUsefulBlocks = ["p>", "p ", "h1", "h2", "h3", "ul"]
        let combine = String([first, second])
        return PotentiallyUsefulBlocks.contains(combine)
    }
/*
    takes in a html string as String
    returns the parsed article
*/
    func getArticle(webString: String) -> String {
        var article = String()
        var idx = webString.startIndex
        var currentChar: Character
        var inBlock = false
        while idx < webString.endIndex {
            currentChar = webString[idx]
            if currentChar == "<" {
                inBlock = true
            }else if inBlock {
                let nextChar = webString[idx.successor()]
                idx = advanceToEndOfBlock(webString, idx: idx).endIdx
                if (isUsefulBlock(currentChar, second: nextChar)) {
                    let info = extractSentenceFromBlock(webString, idx: idx)
//                    print("sentence is: \(info.sentence)")
                    if containsLetters(info.sentence) {
                        article += info.sentence + "\n"
                    } else {
                        article += "\n"
                    }
                    idx = info.idx
                }
                inBlock = false
            }
            idx = idx.successor()
        }
        return article
    }
}
