//
//  FPAMainViewController.h
//  Reasons To Be Tearful
//
//  Created by Daniel Harvey on 03/03/2016.
//  Copyright (c) 2016 Daniel Harvey. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AVFoundation;

@class FPADataFetcher;
@class FPAAudioPlayer;
@class FPAVisualiser;

@interface FPAMainViewController : UIViewController

@property (nonatomic, strong) FPADataFetcher * dataFetcher;
@property (nonatomic, strong) NSMutableArray * fetcherPile;
@property (nonatomic, strong) NSMutableArray * playerPile;
@property (nonatomic, strong) NSMutableArray * visualPile;

@property (nonatomic) NSUInteger numberOfPlayers;
@property (nonatomic, strong) NSMutableDictionary * soundsList;
@property (nonatomic, strong) FPAVisualiser * visualiser;

@property (nonatomic) BOOL backgroundMode; // when app is in background, keep triggering sounds when others finish

@property (nonatomic, strong) FPAAudioPlayer * audioPlayer;
@property (nonatomic, strong) NSTimer * reasonsTimer;

@property (nonatomic, strong) IBOutlet UILabel *blurb;

@property (nonatomic,strong) NSMutableString * reasonString;

@property (nonatomic) float currentRed;
@property (nonatomic) float currentGreen;
@property (nonatomic) float currentBlue;

@property (nonatomic) float targetRed;
@property (nonatomic) float targetGreen;
@property (nonatomic) float targetBlue;

@property (nonatomic) BOOL touchDown;
@property (nonatomic, strong) NSMutableString * deviceToken;

@property (nonatomic) CFTimeInterval firstTimestamp;
@property (nonatomic) CFTimeInterval touchTime;
@property (nonatomic, weak) CADisplayLink *displayLink;

-(void)startReasonsLoop;
-(void)getNewReason;
-(void)gotNewReason:(NSData *)data;
-(void)couldntGetReason;

-(void)getNewSounds;
-(void)gotNewSounds:(NSData *)data;
-(void)couldntGetSounds;
-(void)stopAllSounds;

-(void)createPlayerPile;
-(NSUInteger)playerIsFree;
-(BOOL)areAnyPlayersPlaying;
-(NSUInteger)getRandomSound;
-(NSMutableDictionary *)getAvailableSounds;

-(void)updateLabelView;

-(void)updateVisuals;

-(UIColor *)getTextColor;
-(UIColor *)getBackColor;
-(void)backToBlack;
-(void)chooseRandomColour;
-(void)doColourFade;
-(void)updateColours;


@end
