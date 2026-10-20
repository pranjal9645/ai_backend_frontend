//
//  RateLimitCooldown.swift
//  AIKnowledgePlatform11
//
//  Created by Pranjal Singh on 12/10/26.
//

import Foundation
import Combine

@MainActor
final class RateLimitCooldown : ObservableObject
{
    @Published private(set) var remainingSeconds : Int = 0
    
    private var cooldownTask : Task<Void , Never>?
    
    var isActive : Bool
    {
        remainingSeconds > 0
    }
    
    func start(seconds : TimeInterval?)
    {
        guard let seconds , seconds > 0 else
        {
            return
        }
        
        cooldownTask?.cancel()
        
        remainingSeconds = Int(ceil(seconds))
        
        cooldownTask = Task{
            [weak self] in
            
            
            while let self , self.remainingSeconds > 0
            {
                do
                {
                    try await Task.sleep(for: .seconds(1))
                }catch
                {
                    return
                }
                
                guard !Task.isCancelled else
                {
                    return
                }
                
                self.remainingSeconds = max( 0 , self.remainingSeconds - 1)
            }
        }
    }
    
    func cancel()
    {
        cooldownTask?.cancel()
        cooldownTask = nil
        remainingSeconds = 0
    }
    
    deinit
    {
        cooldownTask?.cancel()
    }
}
