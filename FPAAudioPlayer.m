//
//  FPAAudioPlayer.m
//  Reasons To Be Tearful
//
//  Created by Daniel Harvey on 03/04/2016.
//  Copyright © 2016 Daniel Harvey. All rights reserved.
//

#import "FPAAudioPlayer.h"
#import "FPAMainViewController.h"
#import "FPAVisualiser.h"
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
    if (self.mvc.backgroundMode) {
        [self.mvc getNewSounds]; // when in background keep the party going forever
        [self.mvc getNewSounds]; // in fact, ensure maximum noises
    }
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
            self.visualiser.drawColor=[self.visualiser getRandomColor];
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
        self.player.volume = self.player.volume + 0.005;
//        NSLog(@"volume is %f",self.player.volume);
        [self performSelector:@selector(doVolumeFade) withObject:nil afterDelay:0.1];
    } else {
        self.player.volume=maxVolume;
        
    }
}

// fade out and stop player
-(void)doFadeOut {
    NSLog(@"doFadeOut of player %d",self.playerNumber);
    if (self.player.volume>0) {
        self.player.volume=self.player.volume-0.01;
        [self performSelector:@selector(doFadeOut) withObject:nil afterDelay:0.1];
    } else {
        [self.player stop];
        NSLog(@"stopped player %d",self.playerNumber);
        self.playing=false;
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
    if (volume>0) volume=0;
    volume=volume/-160;
    return 1-volume;
}

-(float)getCurrentPosition {
    if (self.playing==false) return 0;
    if (self.player.duration==0 || self.player.currentTime==0) return 0; //avoid stinky divide by zero
    float position=self.player.currentTime/self.player.duration;
    return position;
}

-(float)getCurrentPan {
    if (self.playing==false) return 0;
    float pan=(self.player.pan+1)/2;
    return pan;
}

#pragma mark Visuals and shit

-(void)updateVisuals {
    float pan=[self getCurrentPan];
    float volume=[self getCurrentVolume];
    float position=[self getCurrentPosition];
    
    self.visualiser.x=position;
    self.visualiser.y=pan*((volume/5)+0.8);
    
    float fadePos=(position*2)-1;
    if (fadePos<0) fadePos=-fadePos;
//    self.visualiser.z=1-fadePos;
    self.visualiser.z=self.player.volume;

//    UIColor *drawColor=[self.mvc getTextColor];
  //  self.visualiser.drawColor=drawColor;
    [self.visualiser setNeedsDisplay];
}

@end
