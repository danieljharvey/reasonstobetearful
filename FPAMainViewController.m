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

    self.dataFetcher=[[FPADataFetcher alloc] initWithViewController:self];
    [self getNewReason];
    
    self.audioFetcher=[[FPADataFetcher alloc] initWithViewController:self];
    self.audioFetcher.fetchingReasons=false; // so feedback goes to the right place
    
    [self createPlayerPile];
//    [self getNewSounds];
    [self registerPush];
    [self startReasonsLoop];
    
}

-(void)viewWillDisappear:(BOOL)animated {
    NSLog(@"stopping reasons loop...");
    [self.reasonsTimer invalidate];
}

-(void)createPlayerPile {
    NSLog(@"create player pile for %d players",self.numberOfPlayers);
    if (self.playerPile) return; // already done
    self.playerPile=[[NSMutableArray alloc] init];
    for (NSUInteger i=0; i<self.numberOfPlayers; i++) {
        FPAAudioPlayer * audioPlayer=[[FPAAudioPlayer alloc] initWithViewController:self playerNumber:i];
        [self.playerPile addObject:audioPlayer];
    }
}

#pragma mark Reasons

- (void)startReasonsLoop {
    NSLog(@"starting reasons loop...");
    self.reasonsTimer=[NSTimer scheduledTimerWithTimeInterval:30.0
                                     target:self
                                   selector:@selector(getNewReason)
                                   userInfo:nil
                                    repeats:YES];
}

-(void)getNewReason {
    [self.dataFetcher fetchNewReason];
    if ([self playerIsFree]) {
        NSLog(@"player is free");
        [self getNewSounds];
    } else {
        NSLog(@"no players are free");
    }
}

-(void)gotNewReason:(NSData *)data {
    NSError *error;
    
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                         options:kNilOptions
                                                           error:&error];
    NSLog(@"data is %@",json);
    
    
    if ([json objectForKey:@"blurb"]!=nil) {
        [self.reasonString setString:[json objectForKey:@"blurb"]];
        [self updateLabelView];
    } else {
        [self couldntGetReason];
    }
}

-(void)couldntGetReason {
    // put up one of the defaults
    if (self.reasonString) {
        // leave current one
    } else {
        [self.reasonString setString:@"Not found"];
        [self updateLabelView];
    }
}

-(void)updateLabelView {
    if ([self.blurb.text isEqualToString:self.reasonString]) {
        NSLog(@"String is the same, do nothing");
    } else {
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
    [self.audioFetcher fetchNewSounds];
}

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
    // usually means no internet connection, try again in 30 seconds
    [NSTimer scheduledTimerWithTimeInterval:30.0
                                     target:self
                                   selector:@selector(getNewSounds)
                                   userInfo:nil
                                    repeats:NO];
}

-(BOOL)playerIsFree {
    for (FPAAudioPlayer *thisAudioPlayer in self.playerPile) {
        if (thisAudioPlayer.playing==false) {
            return true;
        }
    }
    return false;
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


@end
