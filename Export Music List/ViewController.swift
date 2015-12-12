//
//  ViewController.swift
//  Export Music List
//
//  Created by Ansèlm Joseph on 12/12/15.
//  Copyright © 2015 an23lm. All rights reserved.
//

import Cocoa

class song {
    var name: String = ""
    var artist: String = ""
    var album: String = ""
    
    init () {}
}

class ViewController: NSViewController, NSXMLParserDelegate {

    var parser = NSXMLParser()
    var elementValue: String?
    var success: Bool = false
    var fileURL: NSURL = NSURL()
    
    var dictCount = 0
    var keyCount = 0
    
    var isName = false
    var isAlbum = false
    var isArtist = false
    
    var songInfo: [song] = []
    
    var tempName = ""
    var tempAlbum = ""
    var tempArtist = ""
    var currentElementName = ""
    var currentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        if elementName == "dict" {
            dictCount++
        }
        if dictCount == 3 {
            if elementName == "key" {
                keyCount++
            }
        }
        if keyCount == 2 {
            if elementName == "string" {
                isName = true
            }
        }
        else if keyCount == 3 {
            if elementName == "string" {
                isArtist = true
            }
        }
        else if keyCount == 5 {
            if elementName ==  "string" {
                isAlbum = true
            }
        }
        
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        
        if isName {
            tempName += string
        }
        else if isArtist {
            tempArtist += string
        }
        else if isAlbum {
            tempAlbum += string
        }
        
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "dict" {
            dictCount--
            keyCount = 0
        }
        
        if isName {
            songInfo.append(song())
            songInfo.last?.name = tempName
            tempName = ""
            isName = false
            print(songInfo.last?.name)
        }
        else if isArtist {
            songInfo.last?.artist = tempArtist
            tempArtist = ""
            isArtist = false
        }
        else if isAlbum {
            songInfo.last?.album = tempAlbum
            tempAlbum = ""
            isAlbum = false
        }
        
    }
    
    func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
        print("parseErrorOccurred: \(parseError)")
    }
    
    
    @IBAction func selectAnImageFromFile(sender: AnyObject) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        
        openPanel.beginWithCompletionHandler { (result) -> Void in
            if result == NSFileHandlingPanelOKButton {
                
                self.fileURL = (openPanel.URL?.filePathURL)!
                self.readFile(self.fileURL)
                
            }
        }
    }
    
    func readFile (url: NSURL) {
        
        parser = NSXMLParser(contentsOfURL: url)!
        parser.delegate = self
        parser.shouldProcessNamespaces = false
        parser.shouldReportNamespacePrefixes = false
        parser.shouldResolveExternalEntities = false
        success = parser.parse()

        if success {
            print(songInfo.count)
            print("Writing to a file")
            let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DesktopDirectory, inDomains: .UserDomainMask).first! as NSURL
            let path = documentsUrl.URLByAppendingPathComponent("music-list.txt")
            print(path)
            
            var string = "Music List\n"
            
            do {
                try string.writeToURL(path, atomically: true, encoding: NSUTF8StringEncoding)
            }
            catch let error as NSError {
                print(error)
            }
            
            string = ""
            
            for song in songInfo {
                string += "\"" + song.name + "\"" + " by " + song.artist + " from " + song.album + "\n"
            }
            
            let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            
            do {
                let fileHandle = try NSFileHandle(forWritingToURL: path)
                fileHandle.seekToEndOfFile()
                fileHandle.writeData(data!)
                fileHandle.closeFile()
                print("done")
            }
            catch let error as NSError {
                print(error)
            }
            
            
            /*
            for song in songInfo {
                do {
                    try song.name.writeToURL(path, atomically: true, encoding: NSUTF8StringEncoding)
                }
                catch let error as NSError {
                    print(error)
                }
            }
            */
        }
        else {
            print("nope")
        }
    
    }
    
}

