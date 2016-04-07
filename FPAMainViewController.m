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


@implementation FPAMainViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.reasonString=[[NSMutableString alloc] init];

    _targetRed=0;
    _targetGreen=0;
    _targetBlue=0;
    _currentRed=0;
    _currentGreen=0;
    _currentBlue=0;
    [self doColourFade]; // start graphics timer
    
    self.dataFetcher=[[FPADataFetcher alloc] initWithViewController:self fetcherNumber:100];
    [self couldntGetReason]; // show default
    [self registerPush];
    [self startReasonsLoop];
    
}

-(void)viewWillDisappear:(BOOL)animated {
    NSLog(@"stopping reasons loop...");
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
    for (NSUInteger i=1; i<=self.numberOfPlayers; i++) {
        FPAAudioPlayer * audioPlayer=[[FPAAudioPlayer alloc] initWithViewController:self playerNumber:i];
        [self.playerPile addObject:audioPlayer];
        FPADataFetcher * dataFetcher=[[FPADataFetcher alloc] initWithViewController:self fetcherNumber:i];
        dataFetcher.fetchingReasons=false;
        dataFetcher.audioPlayer=audioPlayer; // link the two
        [self.fetcherPile addObject:dataFetcher];
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
    [self getVolumeLevels];
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

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken{
    
    NSLog(@"deviceToken: %@", deviceToken);
    NSString * token = [NSString stringWithFormat:@"%@", deviceToken];
    //Format token as you need:
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@"<" withString:@""];
    
}

# pragma mark audio levelling

-(void)getVolumeLevels {
    NSMutableArray *levels=[[NSMutableArray alloc] init];
    for (FPADataFetcher *thisDataFetcher in self.fetcherPile) {
        float volume=[thisDataFetcher.audioPlayer getCurrentVolume];
        NSNumber *num = [NSNumber numberWithFloat:volume];
        [levels addObject:num];
    }
    NSLog(@"levels are %@",levels);
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
    // red
    if (_currentRed>_targetRed) {
        _currentRed=_currentRed-0.01;
    } else if (_currentRed <_targetRed) {
        _currentRed=_currentRed+0.05;
        if (_currentRed >_targetRed) _currentRed=_targetRed; // stop glitching
    }
    if (_currentRed>1) _currentRed=1;
    if (_currentRed<0) _currentRed=0;

    // green
    if (_currentGreen>_targetGreen) {
        _currentGreen=_currentGreen-0.01;
    } else if (_currentGreen <_targetGreen) {
        _currentGreen=_currentGreen+0.05;
        if (_currentGreen >_targetGreen) _currentGreen=_targetGreen; // stop glitching
    }
    if (_currentGreen>1) _currentGreen=1;
    if (_currentGreen<0) _currentGreen=0;

    // blue
    if (_currentBlue>_targetBlue) {
        _currentBlue=_currentBlue-0.01;
    } else if (_currentBlue <_targetBlue) {
        _currentBlue=_currentBlue+0.05;
        if (_currentBlue >_targetBlue) _currentBlue=_targetBlue; // stop glitching
    }
    if (_currentBlue>1) _currentBlue=1;
    if (_currentBlue<0) _currentBlue=0;

    [self updateColours];
    [self performSelector:@selector(doColourFade) withObject:nil afterDelay:0.01];
}

-(void)updateColours {
    UIColor *backColor = [UIColor colorWithRed:_currentRed green:_currentGreen blue:_currentBlue alpha:1.0f];
    UIColor *textColor = [UIColor colorWithRed:(1-(_currentRed/2)) green:(1-(_currentGreen/2)) blue:(1-(_currentBlue/2)) alpha:1.0f];
    
    self.blurb.textColor =textColor;
    self.view.backgroundColor=backColor;
    
}

#pragma mark touches

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self chooseRandomColour];
    [self getNewSounds];
}@end
