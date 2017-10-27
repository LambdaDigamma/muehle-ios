//
//  GameTests.swift
//  MuehleTests
//
//  Created by Lennart Fischer on 27.10.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import XCTest
@testable import Muehle

class GameTests: XCTestCase, GameDelegate {
    
    var game = Game()
    
    override func setUp() {
        super.setUp()
        
        
        
    }
    
    override func tearDown() {
        
        
        
        super.tearDown()
    }
    
    func test_init_mode() {
        
        let mode = GameMode.pvp
        let game = Game(mode: mode)
        
        XCTAssertTrue(game.mode == mode)
        
    }
    
    func test_validCoordinates() {
        
        let game = Game()
        
        XCTAssertTrue(game.isValid(Coordinate(col: 1, row: 1)))
        XCTAssertFalse(game.isValid(Coordinate(col: 2, row: 1)))
        
    }
    
    func testFullPVPGame() {
        
        // State: Insertation
        
        
        
        
        
        
        
    }
    
    func place(tile: Tile) {
        
    }
    
    func remove(tile: Tile) {
        
    }
    
    func playerCanRemove(player: Player) {
        
    }
    
    func changedMoving(player: Player) {
        
    }
    
    func changedState(_ state: State) {
        
    }
    
    func move(tile: Tile) {
        
    }
    
    func playerHasWon(_ player: Player) {
        
    }
    
    func moveAITile(turn: Turn) {
        
    }
    
}
