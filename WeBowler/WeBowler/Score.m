//
//  Score.m
//  WeBowler
//
//  Created by Loaner on 10/29/14.
//  Copyright (c) 2014 Sage. All rights reserved.
//

#import "Score.h"

@implementation Score

const NSInteger TOTAL_THROWS = 21;
NSInteger totalThrows[TOTAL_THROWS];
NSInteger throw;

-(Score*) init
{
    throw = 0;
    self = [super init];
    return self;
}

- (void) AddFrameToScore:(NSInteger)first secondThrow:(NSInteger)second
{
    totalThrows[throw] = first;
    throw++;
    totalThrows[throw] = second;
    throw++;
}

-(NSInteger) GetScore
{
    NSInteger score = 0;
    for (int i=0; i<TOTAL_THROWS; i++)
    {
        if (totalThrows[i] != nil)
        {
            score += totalThrows[i];
        }
    }
    return score;
}


@end
