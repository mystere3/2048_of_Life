//
//  GameModel.swift
//  2048 of Life
//
//  Created by Silissa Kenney on 3/3/18.
//  Copyright © 2018 Eric Lehmann. All rights reserved.
//

import UIKit

/// A protocol that establishes a way for the game model to communicate with its parent view controller.
protocol GameModelProtocol : class {
    func scoreChanged(to score: Int)
    func moveOneTile(from: (Int, Int), to: (Int, Int), value: Int)
    func moveTwoTile(from: ((Int, Int), (Int, Int)), to: (Int, Int), value: Int)
    func insertTile(at location: (Int, Int), withValue value: Int)
}

/// A class representing the game state and game logic for swift-2048. It is owned by a NumberTileGame view controller.
class GameModel: NSObject {
    let dimension: Int
    let threshold: Int
    
    var score: Int = 0 {
        didSet {
            delegate.scoreChanged(to: score)
        }
    }
    var gameboard: SquareGameboard<TileObject>
    
    unowned let delegate : GameModelProtocol
    
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
        gameboard = SquareGameBoard(dimension: d, initialValue: .empty)
        super.init()
    }
    
    /// Reset the game state.
    func reset() {
        score = 0
        gameboard.setAll(.Empty)
        queue.removeAll(keepCapacity: true)
        timer.invalidate()
    }
    
    /// Order the game model to perform a move (because the user swiped their finger). The queue enforces a delay of a few milliseconds between each move.
    func queueMove(direction: MoveDirection, onCompletion: @escaping (Bool) -> ()) {
        guard queue.count <= maxCommands else {
            // Queue is wedged. This should never happen in practice.
            return
        }
        queue.append(MoveCommand(direction: direction, completion: onCompletion))
        if !timer.isValid {
            // Timer isn't running, so fire the event immediately
            timerFired(timer)
        }
    }
    
    /// Inform the game model that the move delay timer fired. Once the timer fires, the game model tries to execute a
    /// single move that changes the game state.
    @objc func timerFired(_: Timer) {
        if queue.count == 0 {
            return
        }
        // Go through the queue until a valid command is run or the queue is empty
        
        var changed = false
        while queue.count > 0 {
            let command = queue[0]
            queue.remove(at: 0)
            changed = performMove(direction: command.direction)
            command.completion(changed)
            if changed {
                // If the command doesn't change anything, we immediately run the next one.
                break
            }
        }
        if changed {
            timer = Timer.scheduledTimer(timeInterval: queueDelay,
                                         target: self,
                                         selector: #selector(GameModel.timerFired(_:)),
                                         userInfo: nil,
                                         repeats: false)
        }
    }

    //---------------------------------------------------------------------------------------

// Insert tile with a given value at a position upon the gameboard.
    func insertTile(at location: (Int, Int), value: Int) {
        let (x,y) = location
        if case .empty = gameboard[x, y] {
            gameboard[x, y] = TileObject.tile(value)
            delegate.insertTile(at: location, withValue: value)
        }
    }
    
    // Insert a tile with a given value at a random open position upon the gameboard.
    func insertTileAtRandomLocation(withValue value: Int) {
        let openSpots = gameboardEmptySpots()
        if openSpots.isEmpty {
            // No more open spots; do nothing
            return
        }
        // Randomly select an open spot, and put a new tie there.
        let idx = Int(arc4random_uniform(UInt32(openSpots.count-1)))
        let (x, y) = openSpots[idx]
        insertTile(at: (x, y), value: value)
    }









}
        











