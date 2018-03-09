//
//  GameModel.swift
//  2048 of Life
//
//  Created by Silissa Kenney on 3/3/18.
//  Copyright © 2018 Eric Lehmann. All rights reserved.
//

import UIKit

protocol GameModelProtocol : class {
    func scoreChange(score: Int)
    func moveOneTile(from: (Int, Int), to: (Int, Int), value: Int)
    func moveTwoTile(from: ((Int, Int), (Int, Int)), to: (Int, Int), value: Int)
    func insertTile(location: (Int, Int), value: Int)
}

class GameModel: NSObject {
    let dimension: Int
    let threshold: Int
    
    var score: Int = 0 {
        didSet {
            delegate.scoreChanged(score)
        }
    }
    var gameboard: SquareGameboard<TileObject>
    
    let delegate: GameModelProtocol
    
    var queue: [MoveCommand]
    var timer: Timer
    
    let maxCommands = 100
    let queueDelay = 0.3
    
    init(dimension d: Int, threshold t: Int, delegate: GameModelProtocol) {
        dimension = d
        threshold = t
        self.delegate = delegate
        queue = [MoveCommand]()
        timer = Timer()
        gameboard = SquareGameBoard(dimension: d, initialValue: .Empty)
        super.init()
    }
    
    func reset() {
        score = 0
        gameboard.setAll(.Empty)
        queue.removeAll(keepCapacity: true)
        timer.invalidate()
    }
    
    func queueMove(direction: MoveDirection, completion: (Bool) -> ()){
        if queue.count > maxCommands {
            return
        }
        
        let command = MoveCommand(d: direction, c: completion)
        queue.append(command)
        if(!timer.valid) {
            timerFired(timer)
        }
    }
    
    func timerFired(timer: Timer) {
        if queue.count == 0 {
            return
        }
        
        
        var changed = false
        while queue.count > 0 {
            let command = queue[0]
            queue.removeAtIndex(0)
            changed = preformMove(command.direction)
            command.completion(changed)
            if changed {
                break
            }
        }
        if changed {
            self.timer = Timer.scheduledTimer(withTimeInterval: <#T##TimeInterval#>, repeats: <#T##Bool#>, block: <#T##(Timer) -> Void#>)
        }
    }
}











