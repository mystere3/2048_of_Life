//
//  ViewController.swift
//  2048_of_Life
//
//  Created by Silissa Kenney on 3/7/18.
//  Copyright © 2018 Eric Lehmann. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startGameButtonTapped(sender: UIButton) {
        let game = GameViewController(dimension: 8, threshold: 2048)
        self.presentViewController(game, animated: true, completion: nil)
    }
    
}

