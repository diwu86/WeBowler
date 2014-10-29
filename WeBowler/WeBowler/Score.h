//
//  Score.h
//  WeBowler
//
//  Created by Loaner on 10/29/14.
//  Copyright (c) 2014 Sage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Score : NSObject

- (void) AddFrameToScore:(NSInteger)first secondThrow:(NSInteger)second;

-(NSInteger) GetScore;

@end
