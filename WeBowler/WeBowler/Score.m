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

- (void) AddStrikeToScore
{
    totalThrows[throw] = 10;
    throw++;
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
    NSInteger turn = 0;
    
    for (int i=0; totalThrows[i] != nil && turn<10; i++, turn++)
    {
        if(totalThrows[i] == 10)
        {
            score += 10 + totalThrows[i+1] + totalThrows[i+2];
        }
        else if(totalThrows[i+1] != nil && totalThrows[i] + totalThrows[i+1] == 10)
        {
            if(totalThrows[i+2] != nil)
            {
                score += 10 + totalThrows[i+2];
            }
            else
            {
                score += 10;
            }
            i++;
        }
        else
        {
            if(totalThrows[i+1] != nil)
            {
                score += totalThrows[i] + totalThrows[i+1];
            }
            else
            {
                score += totalThrows[i];
            }
            i++;
        }
    }
    return score;
}


@end
