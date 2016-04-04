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

@interface FPAMainViewController : UIViewController

@property (nonatomic, strong) FPADataFetcher * dataFetcher;
@property (nonatomic, strong) FPADataFetcher * audioFetcher;
@property (nonatomic, strong) NSMutableArray * playerPile;
@property (nonatomic) NSUInteger numberOfPlayers;

@property (nonatomic, strong) FPAAudioPlayer * audioPlayer;
@property (nonatomic, strong) NSTimer * reasonsTimer;

@property (nonatomic, strong) IBOutlet UILabel *blurb;

@property (nonatomic,strong) NSMutableString * reasonString;

-(void)startReasonsLoop;
-(void)getNewReason;
-(void)gotNewReason:(NSData *)data;
-(void)couldntGetReason;

-(void)getNewSounds;
-(void)gotNewSounds:(NSData *)data;
-(void)couldntGetSounds;

-(void)createPlayerPile;
-(BOOL)playerIsFree;

-(void)updateLabelView;



@end
