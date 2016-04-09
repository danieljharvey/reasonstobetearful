//
//  FPAMainViewController.m
//  Reasons To Be Tearful
//
//  Created by Daniel Harvey on 03/03/2016.
//  Copyright (c) 2016 Daniel Harvey. All rights reserved.
//

#import "FPAMainViewController.h"
#import "FPADataFetcher.h"
#import "FPAAudioPlayer.h"
#import "FPAVisualiser.h"
#import <QuartzCore/QuartzCore.h>

@implementation FPAMainViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.reasonString=[[NSMutableString alloc] init];
    
    self.deviceToken =[[NSMutableString alloc] init];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    // set colours to default
    self.targetRed=0;
    self.targetGreen=0;
    self.targetBlue=0;
    self.currentRed=0;
    self.currentGreen=0;
    self.currentBlue=0;
    
//    [self doColourFade]; // start graphics timer
    
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(doColourFade)];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    self.displayLink=displayLink; // keep pointer for stuff
    
    [self updateVisuals];
    
    self.dataFetcher=[[FPADataFetcher alloc] initWithViewController:self fetcherNumber:100];
    [self couldntGetReason]; // show default
    [self registerPush];
    [self startReasonsLoop];
    
}

-(void)viewWillDisappear:(BOOL)animated {
    NSLog(@"stopping reasons loop...");
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self.reasonsTimer invalidate];
}

-(void)createPlayerPile {
//    NSLog(@"create player pile for %d players",self.numberOfPlayers);
    if (self.playerPile) return; // already done
    if (!self.soundsList) return; // without this whats the point?
//    if (self.numberOfPlayers>[self.soundsList count]) self.numberOfPlayers=[self.soundsList count]; // don't do this - instead make idle players that may activate when there are more sounds
    NSLog(@"create player pile for %d players",self.numberOfPlayers);
    self.fetcherPile=[[NSMutableArray alloc] init];
    self.playerPile=[[NSMutableArray alloc] init];
    self.visualPile=[[NSMutableArray alloc] init];
    for (NSUInteger i=1; i<=self.numberOfPlayers; i++) {
        FPAAudioPlayer * audioPlayer=[[FPAAudioPlayer alloc] initWithViewController:self playerNumber:i];

        FPADataFetcher * dataFetcher=[[FPADataFetcher alloc] initWithViewController:self fetcherNumber:i];
        dataFetcher.fetchingReasons=false;
        dataFetcher.audioPlayer=audioPlayer; // link the two

        FPAVisualiser * visualiser=[[FPAVisualiser alloc] initWithViewController:self visualNumber:i];
        
        audioPlayer.visualiser=visualiser;
        
        [self.playerPile addObject:audioPlayer];
        [self.fetcherPile addObject:dataFetcher];
        [self.visualPile addObject:visualiser];
    }
}

#pragma mark Reasons

- (void)startReasonsLoop {
    NSLog(@"starting reasons loop...");
    self.reasonsTimer=[NSTimer scheduledTimerWithTimeInterval:10.0
                                     target:self
                                   selector:@selector(getNewReason)
                                   userInfo:nil
                                    repeats:YES];
}

-(void)getNewReason {
    [self.dataFetcher fetchNewReason];
    if ([self playerIsFree]!=false) {
        NSLog(@"player is free");
//        [self getNewSounds]; // wait for user input
    } else {
        NSLog(@"no players are free");
    }
}

-(void)gotNewReason:(NSData *)data {
    NSError *error;
    
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                         options:kNilOptions
                                                           error:&error];
//    NSLog(@"data is %@",json);
    
    if ([json objectForKey:@"sounds"]!=nil) {
        self.soundsList=[json objectForKey:@"sounds"];
    }
    
    if ([json objectForKey:@"blurb"]!=nil) {
        [self.reasonString setString:[json objectForKey:@"blurb"]];
        [self updateLabelView];
    } else {
        [self couldntGetReason];
    }
}

-(void)couldntGetReason {
    // put up one of the defaults
    NSLog(@"Couldn't get reason string");
    NSLog(@"current one is %@",self.reasonString);
    if (self.reasonString.length>0) {
        // leave current one
    } else {
        [self.reasonString setString:@"reasons to be tearful"];
        [self updateLabelView];
    }
}

-(void)updateLabelView {
    if ([self.blurb.text isEqualToString:self.reasonString]) {
        NSLog(@"String is the same, do nothing");
    } else {
        [self backToBlack];
        [UIView animateWithDuration:1.0
                         animations:^{
                             self.blurb.alpha = 0.0;
                         }
                         completion:^(BOOL finished){
                            self.blurb.text=self.reasonString;
                             self.blurb.numberOfLines = 0;
                             [self.blurb sizeToFit];
                             [UIView animateWithDuration:1.0
                                              animations:^{
                                                  self.blurb.alpha = 1.0;
                                              }];
                         }];
    }

}

#pragma mark Sounds

-(void)getNewSounds {
    NSUInteger playerNumber = [self playerIsFree];
    if (playerNumber==false) return; // no players
    for (FPADataFetcher *thisFetcher in self.fetcherPile) {
        if (thisFetcher.fetcherNumber==playerNumber) {
            NSUInteger soundID=[self getRandomSound];
            if (soundID>0) {
                [thisFetcher fetchNewSounds:soundID];
            }
        }
    }
}

 // this is obselete now - audio player is found
-(void)gotNewSounds:(NSData *)data {
    // send to empty audio player
    for (FPAAudioPlayer *thisAudioPlayer in self.playerPile) {
        if (thisAudioPlayer.playing==false) {
            [thisAudioPlayer streamAudio:data];
            return;
        }
    }
}

-(void)couldntGetSounds {
    // was trying again, now leave that to main loop
}

-(NSUInteger)playerIsFree {
    [self createPlayerPile];
    for (FPADataFetcher *thisDataFetcher in self.fetcherPile) {
        if (thisDataFetcher.busy==false && thisDataFetcher.audioPlayer.playing==false) {
            return thisDataFetcher.fetcherNumber;
        }
    }
    return false;
}

-(BOOL)areAnyPlayersPlaying {
    for (FPAAudioPlayer *thisAudioPlayer in self.playerPile) {
        if (thisAudioPlayer.playing!=false) {
            return true;
        }
    }
    return false;
}

-(NSUInteger)getRandomSound {
    NSLog(@"getRandomSound");
    if (self.soundsList==nil) return 0;
    
    NSDictionary *availableSounds=[self getAvailableSounds];
    if (availableSounds==nil || availableSounds.count==0) return 0; // no sounds left to enjoy
    
    NSArray *array = [availableSounds allKeys];
    int random = arc4random()%[array count];
    NSString *key = [array objectAtIndex:random];

    NSString * soundString = [availableSounds objectForKey: key];
    NSUInteger soundID= [soundString integerValue];
    NSLog(@"We've got %d",soundID);
    return soundID;
}

-(void)stopAllSounds {
    for (FPAAudioPlayer *thisAudioPlayer in self.playerPile) {
        if (thisAudioPlayer.playing!=false) {
            [thisAudioPlayer doFadeOut];
        }
    }
}

// supply self.soundsList minus playing sounds to stop duplication
// important if we want to be able to send single songs

-(NSMutableDictionary *)getAvailableSounds {
    NSMutableDictionary *availableSounds=[[NSMutableDictionary alloc] initWithDictionary:self.soundsList];
    if (availableSounds.count==0) return nil;
    for (FPADataFetcher *thisDataFetcher in self.fetcherPile) {
        if (thisDataFetcher.audioPlayer.playing==true || thisDataFetcher.busy==true) {
            NSUInteger soundID=thisDataFetcher.soundID;
            NSString * soundString=[[NSString alloc] initWithFormat:@"%d",soundID];
            [availableSounds removeObjectForKey:soundString];
        }
    }
    return availableSounds;
}

#pragma mark Push

-(void)registerPush {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
}


# pragma mark audio levelling

-(void)updateVisuals {
    float average=(self.currentRed+self.currentGreen+self.currentBlue)/3;
    for (FPAAudioPlayer *thisAudioPlayer in self.playerPile) {
        thisAudioPlayer.visualiser.alpha=average;
        [thisAudioPlayer updateVisuals];
    }
//    [self performSelector:@selector(updateVisuals) withObject:nil afterDelay:0.1];
}

# pragma mark colour fading

-(void)chooseRandomColour {
    if ([self playerIsFree]==false) return;
    NSDictionary *availableSounds=[self getAvailableSounds];
    if (availableSounds==nil || availableSounds.count==0) return; // no sounds left to enjoy
    
    srand48(arc4random());
    self.targetRed = (drand48()/2)+0.5;
    srand48(arc4random());
    self.targetGreen = (drand48()/2)+0.5;
    srand48(arc4random());
    self.targetBlue = (drand48()/2)+0.5;
     
//    self.targetRed=self.targetGreen=self.targetBlue=0.3; // try white instead
    [self performSelector:@selector(backToBlack) withObject:nil afterDelay:0.5];
}

-(void)backToBlack {
    self.targetRed=0;
    self.targetGreen=0;
    self.targetBlue=0;
}

// hacky as fuck
-(void)doColourFade {
    CFTimeInterval touchLength=CACurrentMediaTime()-self.touchTime;
    
    CFTimeInterval elapsed = (self.displayLink.timestamp - self.firstTimestamp);
    self.firstTimestamp = self.displayLink.timestamp;
    
    // expected unit = 1000/60
    float expected=1.0/60;
    float unit=elapsed/expected*0.01;
    
    if (self.touchTime>0 && touchLength>6) {
        self.blurb.text=@"stop.";
        _currentRed=_currentRed+unit;
        _currentGreen=_currentGreen+unit;
        _currentBlue=_currentBlue+unit;
        
    } else if (self.touchTime>0 && touchLength>4) {
//        self.blurb.text=@"stop?";
        _currentRed=_currentRed+unit;
        if (_currentGreen>0.3) _currentGreen=_currentGreen-unit;
        if (_currentBlue>0.3) _currentBlue=_currentBlue-unit;
        
    } else if (self.touchTime>0 && touchLength>2) {
        
        if (_currentRed<0.4) _currentRed=_currentRed+(unit*0.4);
        if (_currentGreen<0.6) _currentGreen=_currentGreen+(unit*0.4);
        if (_currentBlue<0.4) _currentBlue=_currentBlue+(unit*0.4);
        
    } else if (self.touchTime>0) {
        
        if (_currentRed<0.3) _currentRed=_currentRed+(unit*0.5);
        if (_currentGreen<0.3) _currentGreen=_currentGreen+(unit*0.15);
        if (_currentBlue<0.4) _currentBlue=_currentBlue+(unit*0.2);
        
    } else {
        // red
        if (_currentRed>_targetRed) {
            _currentRed=_currentRed-unit;
        } else if (_currentRed <_targetRed) {
            _currentRed=_currentRed+(unit*5);
            if (_currentRed >_targetRed) _currentRed=_targetRed; // stop glitching
        }

        
        // green
        if (_currentGreen>_targetGreen) {
            _currentGreen=_currentGreen-unit;
        } else if (_currentGreen <_targetGreen) {
            _currentGreen=_currentGreen+(unit*5);
            if (_currentGreen >_targetGreen) _currentGreen=_targetGreen; // stop glitching
        }

        
        // blue
        if (_currentBlue>_targetBlue) {
            _currentBlue=_currentBlue-unit;
        } else if (_currentBlue <_targetBlue) {
            _currentBlue=_currentBlue+(unit*5);
            if (_currentBlue >_targetBlue) _currentBlue=_targetBlue; // stop glitching
        }
    }
    
    if (_currentRed>1) _currentRed=1;
    if (_currentRed<0) _currentRed=0;
    
    if (_currentGreen>1) _currentGreen=1;
    if (_currentGreen<0) _currentGreen=0;
    
    if (_currentBlue>1) _currentBlue=1;
    if (_currentBlue<0) _currentBlue=0;

    [self updateColours];
    [self updateVisuals];
//    [self performSelector:@selector(doColourFade) withObject:nil afterDelay:0.01];
}

-(void)updateColours {

    UIColor *backColor=[self getBackColor];
    UIColor *textColor=[self getTextColor];
    
    self.blurb.textColor =textColor;
    self.view.backgroundColor=backColor;
    
}

-(UIColor *)getBackColor {
    UIColor *backColor = [UIColor colorWithRed:_currentRed green:_currentGreen blue:_currentBlue alpha:1.0f];
    return backColor;
}

-(UIColor *)getTextColor {
    UIColor *textColor = [UIColor colorWithRed:(1-(_currentRed/2)) green:(1-(_currentGreen/2)) blue:(1-(_currentBlue/2)) alpha:1.0f];
    return textColor;
}

#pragma mark touches

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.touchTime=CACurrentMediaTime();
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    CFTimeInterval touchLength=CACurrentMediaTime()-self.touchTime;
    self.touchTime=0;
    NSLog(@"Touch length was %f",touchLength);
    if (touchLength>6) {
        // stop
        self.touchTime=0;
        _targetRed=1;
        _targetGreen=1;
        _targetBlue=1;
        [self stopAllSounds];
        //[self backToBlack];
    } else if (touchLength>4) {
        // this is the 'maybe stop', so do nothing
        [self backToBlack];
    } else {
        if ([self playerIsFree]>0) {
            // add sounds
            [self chooseRandomColour];
            [self getNewSounds];
        } else {
            // no sounds to add
            [self performSelector:@selector(backToBlack) withObject:nil afterDelay:0.5];
        }
    }

}@end
