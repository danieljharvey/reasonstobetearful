//
//  FPAAudioPlayer.h
//  Reasons To Be Tearful
//
//  Created by Daniel Harvey on 03/04/2016.
//  Copyright © 2016 Daniel Harvey. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AVFoundation;
@class FPAMainViewController;
@class FPAVisualiser;

@interface FPAAudioPlayer : NSObject<AVAudioPlayerDelegate>

@property (nonatomic, weak) FPAMainViewController * mvc; // pointer to main program so we can tell it to update when data is fetched
@property (nonatomic, strong) AVAudioPlayer * player;
@property (nonatomic) NSUInteger playerNumber;
@property (nonatomic) BOOL playing;
@property (nonatomic, weak) FPAVisualiser *visualiser;

- (id)initWithViewController:(FPAMainViewController *)viewController playerNumber:(NSUInteger)playerNumber;
- (void)streamAudio:(NSData *)data;
- (void)doVolumeFade;
- (void)doFadeOut;

- (float)getCurrentVolume;
- (float)getCurrentPosition;
- (float)getCurrentPan;

-(void)updateVisuals;

@end
