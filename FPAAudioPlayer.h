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

@interface FPAAudioPlayer : NSObject<AVAudioPlayerDelegate>

@property (nonatomic, weak) FPAMainViewController * mvc; // pointer to main program so we can tell it to update when data is fetched
@property (nonatomic, strong) AVAudioPlayer * player;

- (id)initWithViewController:(FPAMainViewController *)viewController;
- (void)streamAudio:(NSData *)data;
- (void)doVolumeFade;

@end
