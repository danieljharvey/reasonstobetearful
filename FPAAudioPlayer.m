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

-(id)initWithViewController:(FPAMainViewController *)viewController playerNumber:(NSUInteger)playerNumber {
    FPAAudioPlayer *me = [super init];
    if (me) {
        me.mvc=viewController;
        me.playing=false;
        me.playerNumber=playerNumber;
    }
    return me;
}

#pragma mark Audio player delegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    // play another sick tune i guess
    NSLog(@"Play completed I guess");
    self.playing=false;
    [self.mvc getNewSounds];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    NSLog(@"Error! Which is %@",error);
    self.playing=false;
}

-(void)streamAudio:(NSData *)data {
    NSLog(@"FPAAudioPlayer -> streamAudio");
    NSLog(@"Player number %d",self.playerNumber);
    NSError * error;
    self.player = [[AVAudioPlayer alloc] initWithData:data error:&error];

    if (self.player) {
        NSLog(@"player initialised");
        srand48(arc4random());
        
        double x = drand48();
        x=(x*2)-1;
        NSLog(@"Pan to %f",x);
        
/*        if (self.playerNumber % 2 == 0) { // even
            self.player.pan=-0.75;
        } else {
            self.player.pan=0.75;
        }*/
        self.player.pan=x;
        self.player.numberOfLoops = -1;
        self.player.delegate = self;
        self.player.volume = 0;
        [self.player prepareToPlay];
        if (self.player == nil) {
            NSLog(@"%@", [error description]);
        } else {
            NSLog(@"start playing");
            [self.player play];
            self.playing=true;
            [self doVolumeFade];
        }
    } else {
        NSLog(@"%@", [error description]);
    }
}

-(void)doVolumeFade {
    float maxVolume=(1/(float)self.mvc.numberOfPlayers);
    if (self.player.volume < maxVolume) {
        self.player.volume = self.player.volume + 0.0001;
//        NSLog(@"volume is %f",self.player.volume);
        [self performSelector:@selector(doVolumeFade) withObject:nil afterDelay:0.1];
    } else {
        self.player.volume=maxVolume;
    }
}

@end
