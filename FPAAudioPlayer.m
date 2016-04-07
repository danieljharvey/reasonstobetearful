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
    // flag player as available
    NSLog(@"Play completed I guess");
    self.playing=false;
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    NSLog(@"Error! Which is %@",error);
    self.playing=false;
}

-(void)streamAudio:(NSData *)data {
    NSLog(@"FPAAudioPlayer -> streamAudio");
    NSLog(@"Player number %lu",(unsigned long)self.playerNumber);
    NSError * error;
    self.player = [[AVAudioPlayer alloc] initWithData:data error:&error];

    if (self.player) {
        NSLog(@"player initialised");
        srand48(arc4random());
        double x;
        // single sound gets played in the centre
        if (self.mvc.numberOfPlayers==1) {
            x=0;
        } else {
            x = drand48();
            x=(x*2)-1;
        }
        
        //NSLog(@"Pan to %f",x);
        
        self.player.pan=x;
        self.player.numberOfLoops = 0;
        self.player.delegate = self;
        self.player.volume = 0;
        self.player.meteringEnabled=true;
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
//    if (self.mvc.numberOfPlayers>4) maxVolume=maxVolume+1;
    if (self.player.volume < maxVolume) {
        self.player.volume = self.player.volume + 0.001;
//        NSLog(@"volume is %f",self.player.volume);
        [self performSelector:@selector(doVolumeFade) withObject:nil afterDelay:0.1];
    } else {
        self.player.volume=maxVolume;
    }
}

# pragma mark Level monitoring

-(float)getCurrentVolume {
    if (self.playing==false) return 0;
    [self.player updateMeters];
    NSUInteger numChannels=self.player.numberOfChannels;
    float volume=0;
    for (int currChan = 0; currChan < numChannels; currChan++) {
        volume=volume+[self.player averagePowerForChannel:currChan];
    }
    volume=volume/numChannels;
    NSLog(@"player %d at level of %f",self.playerNumber,volume);
    return volume;
}


@end
