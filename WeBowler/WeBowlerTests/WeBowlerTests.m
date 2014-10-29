//
//  WeBowlerTests.m
//  WeBowlerTests
//
//  Created by sbarton on 10/28/14.
//  Copyright (c) 2014 Sage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "Score.h"

@interface WeBowlerTests : XCTestCase

@end

@implementation WeBowlerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testStandardScoring
{
    Score *score = [[Score alloc] init];
    [score AddFrameToScore:3 secondThrow:5];
    NSInteger total = [score GetScore];
    XCTAssert(total == 8);
}

@end
