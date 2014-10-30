//
//  GameScene.m
//  WeBowler
//
//  Created by sbarton on 10/28/14.
//  Copyright (c) 2014 Sage. All rights reserved.
//

#import "GameScene.h"
#import "Score.h"

typedef NS_OPTIONS(uint32_t, PMPhysicsCategory) {
    BBALLCat = 1 << 0, // 0001 = 1
    GUTTER1Cat = 1 << 1, // 0010 = 2
    GUTTER2Cat = 1 << 2, // 0100 = 3
    EdgeCat = 1 << 3, // 1000 = 4
    Pin1Cat = 1 << 4, // 1000 = 5
    Pin2Cat = 1 << 5, // 1000 = 6
    Pin3Cat = 1 << 6, // 1000 = 7
    Pin4Cat = 1 << 7, // 1000 = 8
    Pin5Cat = 1 << 8, // 1000 = 9
    Pin6Cat = 1 << 9, // 1000 = 10
    Pin7Cat = 1 << 10, // 1000 = 11
    Pin8Cat = 1 << 11, // 1000 = 12
    Pin9Cat = 1 << 12, // 1000 = 13
    Pin10Cat = 1 << 13, // 1000 = 14
};

@interface GameScene ()<SKPhysicsContactDelegate>
@property BOOL contentCreated;
@end


@implementation GameScene
{
@private
    SKTextureAtlas* _atlas;
    SKTexture* _bballTexture;
    SKTexture* _gutter1Texture;
    SKTexture* _gutter2Texture;
    SKLabelNode * _hitLabel;
    SKTexture* _pin1Texture;
    int _hits;
    Score *score;
}


-(void)didMoveToView:(SKView *)view
{
/*
    //Setup your scene here
    SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    
    myLabel.text = @"Hello, World!";
    myLabel.fontSize = 65;
    myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                   CGRectGetMidY(self.frame));
    
    [self addChild:myLabel];
*/
    
    if (!self.contentCreated)
    {
        [self createSceneContents];
        score = [[Score alloc] init];
        self.contentCreated = YES;
    }
    
}




/*
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
        
        sprite.xScale = 0.5;
        sprite.yScale = 0.5;
        sprite.position = location;
        
        SKAction *action = [SKAction rotateByAngle:M_PI duration:1];
        
        [sprite runAction:[SKAction repeatActionForever:action]];
        
        [self addChild:sprite];
    }
}
*/

- (void)touchesBegan:(NSSet *) touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    
    SKNode *bball = [self findBBall];
    
    /// Make the bowling ball force be the distance from the touch point
    CGPoint offset = CGPointMake(touchLocation.x - bball.position.x, touchLocation.y - bball.position.y);
    CGFloat length = sqrtf(offset.x * offset.x + offset.y * offset.y);
    
    length = -length;
    
    [bball.physicsBody applyImpulse: CGVectorMake(offset.x/length * BBALL_THRUST, offset.y/length * BBALL_THRUST)];
}


-(void) didBeginContact:(SKPhysicsContact *)contact
{
    NSString * aName = contact.bodyA.node.name;
    NSString * bName = contact.bodyB.node.name;
    NSLog(@"Contact between %@ and %@", aName, bName);
    [self didRegisterHit];
}

-(void) didRegisterHit
{
    
    _hitLabel.text = [NSString stringWithFormat:@"Hits: %d", _hits];
    
    
    /*
    SKNode* node = [self findBBall];
    
    
    if(node.position.y < 0 || node.position.y > 168 || node.position.x < 0 || node.position.x > 1024)
    {
        [node removeFromParent];
        [self addBBall];
    }
     */

}

-(void) didEndContact:(SKPhysicsContact *)contact
{
    NSLog(@"end contact");
    
    SKNode* node = [self findBBall];
    
    if(node.position.x < 350 || node.position.x > 500)
    {
        CGMutablePathRef path = CGPathCreateMutable();
        
        if(node.position.x < 350)
        {
            CGPathMoveToPoint(path, NULL, node.position.x, node.position.y);
            CGPathAddLineToPoint(path, NULL, node.position.x, 2000);
        }
        if(node.position.x > 500)
        {
            CGPathMoveToPoint(path, NULL, node.position.x, node.position.y);
            CGPathAddLineToPoint(path, NULL, node.position.x, 2000);
        }
        
        
        
        SKAction *followline = [SKAction followPath:path asOffset:YES orientToPath:NO duration:5.0];
        [node runAction:[SKAction sequence:@[followline]]];
        [node removeFromParent];
        [self addBBall];
        
        SKNode* node = [self findBBall];
        [node runAction:[SKAction sequence:@[followline]]];
    }

}


- (void)createSceneContents
{
    // Get the textures
    _atlas = [SKTextureAtlas atlasNamed:@"gameTextures"];
    _bballTexture = [_atlas textureNamed:@"Bowling.png"];
    _gutter1Texture = [_atlas textureNamed:@"gutter1.png"];
    _gutter2Texture = [_atlas textureNamed:@"gutter1.png"];
    _pin1Texture = [_atlas textureNamed:@"pin.png"];
    _hits = 0;
    
    self.backgroundColor = [SKColor blackColor];
    self.scaleMode = SKSceneScaleModeAspectFit;
    
    CGRect lane = self.frame;
    lane.size.height -= self.frame.size.height + 100;
    
    
    
    // Add edge physics body for the border
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:lane];
    self.physicsBody.categoryBitMask = EdgeCat;
    
    self.physicsWorld.contactDelegate = self;
    
    [self addBackground];
    
    // Add gutters
    [self addGutters];
    
    // Add BBall
    [self addBBall];
    
    // Add Pins
    [self addPins];
    
    // Add Label
    _hitLabel = [SKLabelNode labelNodeWithFontNamed:@"Courier Bold"];
    _hitLabel.position = CGPointMake(100, 950);
    _hitLabel.fontSize = 30.0;
    _hitLabel.fontColor = [SKColor blackColor];
    _hitLabel.text = @"Hits: 0";
    [self addChild:_hitLabel];
    
    SKAction *readdBBALL = [SKAction sequence: @[
                                                 [SKAction performSelector:@selector(readdBBall) onTarget:self],
                                                 [SKAction waitForDuration:2]
                                                 ]];
    [self runAction: [SKAction repeatActionForever:readdBBALL]];
    
    
    SKAction *readPins = [SKAction sequence: @[
                                                 [SKAction performSelector:@selector(readPins) onTarget:self],
                                                 [SKAction waitForDuration:0]
                                                 ]];
    [self runAction: [SKAction repeatActionForever:readPins]];

}

-(void) addBackground
{
    self.backgroundColor = [SKColor colorWithRed:206 green:206 blue:206 alpha:1.0];
    self.scaleMode = SKSceneScaleModeAspectFit;
}

-(void)readdBBall
{
    SKNode* node = [self findBBall];
    
    //If bball is off the screen, add another
    if(node.position.y < 0 || node.position.y > 1024 || node.position.x < 0 || node.position.x > 768)
    {
        [node removeFromParent];
        [self addBBall];
    }
    
}

-(SKNode *) findBBall
{
    __block SKNode *bball = nil;
    [self enumerateChildNodesWithName:@"bball" usingBlock:^(SKNode *node, BOOL *stop) {
        bball = node;
    }];
    return bball;
}

-(void)addBBall
{
    SKSpriteNode *bball = [SKSpriteNode spriteNodeWithTexture:_bballTexture];
    bball.name = @"bball";
    
    bball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:bball.size.width/2];
    bball.physicsBody.dynamic = YES;
    bball.physicsBody.restitution = 1.0;
    bball.physicsBody.categoryBitMask = BBALLCat;
    bball.physicsBody.collisionBitMask = GUTTER1Cat | EdgeCat;
    
    bball.physicsBody.affectedByGravity = NO;
    
    bball.position = CGPointMake(self.size.width/2, 100);
    
    [self addChild:bball];
}

- (void)addGutters
{
    SKSpriteNode *gutter1 = [SKSpriteNode spriteNodeWithTexture:_gutter1Texture];
    SKSpriteNode *gutter2 = [SKSpriteNode spriteNodeWithTexture:_gutter2Texture];
    
    gutter1.name = @"gutter1";
    
    gutter1.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:gutter1.size];
    //    .physicsBody.dynamic = YES;
    gutter1.physicsBody.dynamic = NO;
    //    .physicsBody.allowsRotation = YES;
    gutter1.physicsBody.allowsRotation = NO;
    gutter1.physicsBody.categoryBitMask = GUTTER1Cat;
    gutter1.physicsBody.collisionBitMask = BBALLCat | EdgeCat;
    gutter1.physicsBody.contactTestBitMask = BBALLCat;
    gutter1.position = CGPointMake(100, 0);
    
    
    gutter2.name = @"gutter2";
    
    gutter2.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:gutter1.size];
    //    .physicsBody.dynamic = YES;
    gutter2.physicsBody.dynamic = NO;
    //    .physicsBody.allowsRotation = YES;
    gutter2.physicsBody.allowsRotation = NO;
    gutter2.physicsBody.categoryBitMask = GUTTER1Cat;
    gutter2.physicsBody.collisionBitMask = BBALLCat | EdgeCat;
    gutter2.physicsBody.contactTestBitMask = BBALLCat;
    gutter2.position = CGPointMake(668, 0);
    
    //gutter1.position = CGPointMake(gutter1.size.width/2, gutter1.size.height/2);
    //gutter2.position = CGPointMake(gutter1.size.width/2, gutter1.size.height/2);
    [self addChild:gutter1];
    [self addChild:gutter2];
    

}

-(void)readPins
{
    //int count = 0;
    for (int i=1; i<11; i++)
    {
        SKNode* pin_node = [self findPin:i];
        
        //If pin is off the screen remove it
        if(pin_node.position.y < 0 || pin_node.position.y > 900 || pin_node.position.x < 0 || pin_node.position.x > 1024 || pin_node.hasActions)
        {
            [pin_node removeFromParent];
            _hits++;
        }
    }
    
    
}

-(SKNode *) findPin: (int) number
{
    __block SKNode *pin1 = nil;
    NSString *pinnumber = [NSString stringWithFormat:@"pin%d",number];
    [self enumerateChildNodesWithName:pinnumber usingBlock:^(SKNode *node, BOOL *stop) {
        pin1 = node;
    }];
    return pin1;
}

-(void)addPins
{
    SKSpriteNode *pin1 = [SKSpriteNode spriteNodeWithTexture:_pin1Texture];
    pin1.name = @"pin1";
    
    pin1.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:pin1.size.width/2];
    pin1.physicsBody.dynamic = YES;
    pin1.physicsBody.restitution = 1.0;
    pin1.physicsBody.categoryBitMask = Pin1Cat;
    pin1.physicsBody.collisionBitMask = GUTTER1Cat | EdgeCat | BBALLCat | Pin1Cat;
    
    pin1.physicsBody.affectedByGravity = NO;
    
    pin1.position = CGPointMake(self.size.width/2, 700);
    
    [self addChild:pin1];
    
    SKSpriteNode *pin2 = [SKSpriteNode spriteNodeWithTexture:_pin1Texture];
    pin2.name = @"pin2";
    
    pin2.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:pin2.size.width/2];
    pin2.physicsBody.dynamic = YES;
    pin2.physicsBody.restitution = 1.0;
    pin2.physicsBody.categoryBitMask = Pin1Cat;
    pin2.physicsBody.collisionBitMask = GUTTER1Cat | EdgeCat | BBALLCat | Pin1Cat;
    
    pin2.physicsBody.affectedByGravity = NO;
    
    pin2.position = CGPointMake(self.size.width/2 - 50, 760);
    
    [self addChild:pin2];
    
    
    SKSpriteNode *pin3 = [SKSpriteNode spriteNodeWithTexture:_pin1Texture];
    pin3.name = @"pin3";
    
    pin3.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:pin3.size.width/2];
    pin3.physicsBody.dynamic = YES;
    pin3.physicsBody.restitution = 1.0;
    pin3.physicsBody.categoryBitMask = Pin1Cat;
    pin3.physicsBody.collisionBitMask = GUTTER1Cat | EdgeCat | BBALLCat | Pin1Cat;
    
    pin3.physicsBody.affectedByGravity = NO;
    
    pin3.position = CGPointMake(self.size.width/2 + 50, 760);
    
    [self addChild:pin3];
    
    
    SKSpriteNode *pin4 = [SKSpriteNode spriteNodeWithTexture:_pin1Texture];
    pin4.name = @"pin4";
    
    pin4.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:pin4.size.width/2];
    pin4.physicsBody.dynamic = YES;
    pin4.physicsBody.restitution = 1.0;
    pin4.physicsBody.categoryBitMask = Pin4Cat;
    pin4.physicsBody.collisionBitMask = GUTTER1Cat | EdgeCat | BBALLCat | Pin1Cat;
    
    pin4.physicsBody.affectedByGravity = NO;
    
    pin4.position = CGPointMake(self.size.width/2 - 100, 820);
    
    [self addChild:pin4];
    
    SKSpriteNode *pin5 = [SKSpriteNode spriteNodeWithTexture:_pin1Texture];
    pin5.name = @"pin5";
    
    pin5.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:pin5.size.width/2];
    pin5.physicsBody.dynamic = YES;
    pin5.physicsBody.restitution = 1.0;
    pin5.physicsBody.categoryBitMask = Pin5Cat;
    pin5.physicsBody.collisionBitMask = GUTTER1Cat | EdgeCat | BBALLCat | Pin1Cat;
    
    pin5.physicsBody.affectedByGravity = NO;
    
    pin5.position = CGPointMake(self.size.width/2, 820);
    
    [self addChild:pin5];
    
    SKSpriteNode *pin6 = [SKSpriteNode spriteNodeWithTexture:_pin1Texture];
    pin6.name = @"pin6";
    
    pin6.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:pin6.size.width/2];
    pin6.physicsBody.dynamic = YES;
    pin6.physicsBody.restitution = 1.0;
    pin6.physicsBody.categoryBitMask = Pin6Cat;
    pin6.physicsBody.collisionBitMask = GUTTER1Cat | EdgeCat | BBALLCat | Pin1Cat;
    
    pin6.physicsBody.affectedByGravity = NO;
    
    pin6.position = CGPointMake(self.size.width/2 + 100, 820);
    
    [self addChild:pin6];
    
    SKSpriteNode *pin7 = [SKSpriteNode spriteNodeWithTexture:_pin1Texture];
    pin7.name = @"pin7";
    
    pin7.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:pin7.size.width/2];
    pin7.physicsBody.dynamic = YES;
    pin7.physicsBody.restitution = 1.0;
    pin7.physicsBody.categoryBitMask = Pin7Cat;
    pin7.physicsBody.collisionBitMask = GUTTER1Cat | EdgeCat | BBALLCat | Pin1Cat;
    
    pin7.physicsBody.affectedByGravity = NO;
    
    pin7.position = CGPointMake(self.size.width/2 - 150, 880);
    
    [self addChild:pin7];
    
    SKSpriteNode *pin8 = [SKSpriteNode spriteNodeWithTexture:_pin1Texture];
    pin8.name = @"pin8";
    
    pin8.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:pin8.size.width/2];
    pin8.physicsBody.dynamic = YES;
    pin8.physicsBody.restitution = 1.0;
    pin8.physicsBody.categoryBitMask = Pin8Cat;
    pin8.physicsBody.collisionBitMask = GUTTER1Cat | EdgeCat | BBALLCat | Pin1Cat;
    
    pin8.physicsBody.affectedByGravity = NO;
    
    pin8.position = CGPointMake(self.size.width/2 - 50, 880);
    
    [self addChild:pin8];
    
    SKSpriteNode *pin9 = [SKSpriteNode spriteNodeWithTexture:_pin1Texture];
    pin9.name = @"pin9";
    
    pin9.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:pin9.size.width/2];
    pin9.physicsBody.dynamic = YES;
    pin9.physicsBody.restitution = 1.0;
    pin9.physicsBody.categoryBitMask = Pin9Cat;
    pin9.physicsBody.collisionBitMask = GUTTER1Cat | EdgeCat | BBALLCat | Pin1Cat;
    
    pin9.physicsBody.affectedByGravity = NO;
    
    pin9.position = CGPointMake(self.size.width/2 + 50, 880);
    
    [self addChild:pin9];
    
    SKSpriteNode *pin10 = [SKSpriteNode spriteNodeWithTexture:_pin1Texture];
    pin10.name = @"pin10";
    
    pin10.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:pin10.size.width/2];
    pin10.physicsBody.dynamic = YES;
    pin10.physicsBody.restitution = 1.0;
    pin10.physicsBody.categoryBitMask = Pin10Cat;
    pin10.physicsBody.collisionBitMask = GUTTER1Cat | EdgeCat | BBALLCat | Pin1Cat;
    
    pin10.physicsBody.affectedByGravity = NO;
    
    pin10.position = CGPointMake(self.size.width/2 + 150, 880);
    
    [self addChild:pin10];
}




-(void)update:(CFTimeInterval)currentTime {
    //Called before each frame is rendered
}


@end
