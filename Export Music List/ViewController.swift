//
//  ViewController.swift
//  Export Music List
//
//  Created by Ansèlm Joseph on 12/12/15.
//  Copyright © 2015 an23lm. All rights reserved.
//

import Cocoa

class song {
    var index: Int = 0
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
    
    var currentElementName = ""
    var currentFoundChar = ""
    var currentIndex = 0
    let blankSpace = NSCharacterSet.whitespaceAndNewlineCharacterSet()
    
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
        
        if elementName == "key" {
            currentElementName = elementName
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        
        currentFoundChar += string
        
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if isName {
            songInfo.last?.name = currentFoundChar
            isName = false
        }
        else if isAlbum {
            songInfo.last?.album = currentFoundChar
            isAlbum = false
        }
        else if isArtist {
            songInfo.last?.artist = currentFoundChar
            isArtist = false
        }
        
        if currentElementName == "key" {
            //print(currentFoundChar)
            currentFoundChar = currentFoundChar.stringByTrimmingCharactersInSet(blankSpace)
            switch currentFoundChar {
            case "Name":
                isName = true
                songInfo.append(song())
                currentIndex++
            case "Artist":
                isArtist = true
            case "Album":
                isAlbum = true
            default: break
            }
            currentFoundChar = ""
        }
        
    }
    
    func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
        print("parseErrorOccurred: \(parseError)")
    }
    
    
    @IBAction func selectAFile(sender: AnyObject) {
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
            
            var count = 0
            var doesExist = true
            let dir = NSSearchPathForDirectoriesInDomains(.DesktopDirectory, .AllDomainsMask, true).first
            let checkValidation = NSFileManager.defaultManager()

            
            var pathString = ""
            
            while doesExist {
            
                pathString = dir! + "/"
                pathString += "music-list" + "-\(count)" + ".txt"
                
                print(pathString)
                
                if (checkValidation.fileExistsAtPath(pathString))
                {
                    count++
                }
                else
                {
                    print("create file");
                    doesExist = false
                }
            }
            
            pathString = "file://" + pathString
            let path = NSURL(string: pathString)
            print(path)
            
            var string = "Music List\n\n"
            
            do {
                try string.writeToURL(path!, atomically: true, encoding: NSUTF8StringEncoding)
            }
            catch let error as NSError {
                print(error)
            }
            
            string = ""
            
            for song in songInfo {
                string += "\"" + song.name + "\""
                if song.artist != "" {
                    string += " by " + song.artist
                }
                if song.album != "" {
                    string += " from " + "\"" + song.album + "\"" + "\n"
                }
            }
            
            let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            
            do {
                let fileHandle = try NSFileHandle(forWritingToURL: path!)
                fileHandle.seekToEndOfFile()
                fileHandle.writeData(data!)
                fileHandle.closeFile()
                print("done")
            }
            catch let error as NSError {
                print(error)
            }
        }
        else {
            print("nope")
        }
    
    }
    
}

