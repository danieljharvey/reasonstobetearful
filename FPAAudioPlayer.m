//
//  FPAAudioPlayer.m
//  Reasons To Be Tearful
//
//  Created by Daniel Harvey on 03/04/2016.
//  Copyright © 2016 Daniel Harvey. All rights reserved.
//

#import "FPAAudioPlayer.h"
#import "FPAMainViewController.h"
@import AVFoundation;

@implementation FPAAudioPlayer

-(id)initWithViewController:(FPAMainViewController *)viewController {
    FPAAudioPlayer *me = [super init];
    if (me) {
        me.mvc=viewController;
    }
    return me;
}

#pragma mark Audio player delegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    // play another sick tune i guess
    NSLog(@"Play completed I guess");
    [self.mvc getNewSounds];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    NSLog(@"Error! Which is %@",error);
}

-(void)streamAudio:(NSData *)data {
    NSLog(@"FPAAudioPlayer -> streamAudio");
    NSError * error;
    self.player = [[AVAudioPlayer alloc] initWithData:data error:&error];

    if (self.player) {
        NSLog(@"player initialised");
        self.player.numberOfLoops = -1;
        self.player.delegate = self;
        self.player.volume = 0;
        [self.player prepareToPlay];
        if (self.player == nil) {
            NSLog(@"%@", [error description]);
        } else {
            NSLog(@"start playing");
            [self.player play];
            [self doVolumeFade];
        }
    } else {
        NSLog(@"%@", [error description]);
    }
}

-(void)doVolumeFade {
    if (self.player.volume < 1) {
        self.player.volume = self.player.volume + 0.0001;
        [self performSelector:@selector(doVolumeFade) withObject:nil afterDelay:0.1];
    } else {
        self.player.volume=1;
    }
}

@end
