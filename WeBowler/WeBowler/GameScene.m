//
//  GameScene.m
//  WeBowler
//
//  Created by sbarton on 10/28/14.
//  Copyright (c) 2014 Sage. All rights reserved.
//

#import "GameScene.h"

typedef NS_OPTIONS(uint32_t, PMPhysicsCategory) {
    BBALLCat = 1 << 0, // 0001 = 1
    GUTTER1Cat = 1 << 1, // 0010 = 2
    GUTTER2Cat = 1 << 2, // 0100 = 3
    EdgeCat = 1 << 3, // 1000 = 4
    Pin1Cat = 1 << 4, // 1000 = 5
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
    
    _hitLabel.text = [NSString stringWithFormat:@"Hits: %d", ++_hits];
    
    
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
}


- (void)createSceneContents
{
    // Get the textures
    _atlas = [SKTextureAtlas atlasNamed:@"gameTextures"];
    _bballTexture = [_atlas textureNamed:@"red_ball.png"];
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
    _hitLabel.position = CGPointMake(100, 900);
    _hitLabel.fontSize = 40.0;
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
    if(node.position.y < 0 || node.position.y > 368 || node.position.x < 0 || node.position.x > 1024)
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
    
    bball.position = CGPointMake(self.size.width/2, 50);
    
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
    SKNode* pin_node1 = [self findPin:1];
    //SKNode* pin_node2 = [self findPin:2];
    //SKNode* pin_node3 = [self findPin:3];
    //SKNode* pin_node4 = [self findPin:4];
    //SKNode* pin_node5 = [self findPin:5];
    
    //If oin is off the screen remove it
    if(pin_node1.position.y < 0 || pin_node1.position.y > 768 || pin_node1.position.x < 0 || pin_node1.position.x > 1024)
    {
        [pin_node1 removeFromParent];
    }
    
}

-(SKNode *) findPin: (int) number
{
    __block SKNode *pin1 = nil;
    [self enumerateChildNodesWithName:@"pin1" usingBlock:^(SKNode *node, BOOL *stop) {
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
    pin1.physicsBody.collisionBitMask = GUTTER1Cat | EdgeCat | BBALLCat;
    
    pin1.physicsBody.affectedByGravity = NO;
    
    pin1.position = CGPointMake(self.size.width/2, 600);
    
    [self addChild:pin1];
}




-(void)update:(CFTimeInterval)currentTime {
    //Called before each frame is rendered
}


@end
