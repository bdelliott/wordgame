//
//  BragFacebook.m
//  wordsleuth
//
//  Created by Brian D. Elliott on 6/7/11.
//  Copyright 2011 Sparkle Software. All rights reserved.
//

#import "BragFacebook.h"
#import "WordURL.h"

@implementation BragFacebook

@synthesize facebook;
@synthesize numGuesses;

@synthesize bragConfirmationView;

- (id)init {
    
    self = [super init];
    
    if (self) {
    
        // init with our facebook app id.
        facebook = [[Facebook alloc] initWithAppId:@"177725138949291"]; 
        
        bragConfirmationView = [[UIAlertView alloc] initWithTitle:@"Brag Posted" message:@"replaceme" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    }
    
    return self;
}

- (void) brag:(NSInteger)score {

    self.numGuesses = score;

    NSArray* permissions =  [[NSArray arrayWithObjects:@"publish_stream", nil] retain];
    
    // check for saved facebook credentials
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *accessToken = [userDefaults stringForKey:@"accessToken"];
    NSDate *expirationDate = [userDefaults objectForKey:@"expirationDate"];

    facebook.accessToken = accessToken;
    facebook.expirationDate = expirationDate;
    
    if ([facebook isSessionValid]) {
        // still have a valid session
        NSLog(@"Facebook session still valid, skipping login");
        [self fbDidLogin];
    } else {
        NSLog(@"Facebook session not valid, need to authorize");
        [facebook authorize:permissions delegate:self];
    }
    
}

- (void)fbDidLogin {
    // user authorized, the app.  post to their wall.
    
    // save the facebook credentials
    [self saveFacebookSession];

    NSString *msg = [NSString stringWithFormat:@"I guessed the Word du Jour in %d %@.", self.numGuesses, self.numGuesses == 1? @"try" : @"tries"];
    
    NSMutableDictionary *d = [[NSMutableDictionary alloc] initWithCapacity:10];
    [d setObject:msg forKey:@"message"];
    
    NSString *wallPostURL = [WordURL getWallPostIconURL];
    [d setObject:wallPostURL forKey:@"picture"];
    
    // bit.ly shortened link to WdJ app store page:
    NSString *link = @"http://bit.ly/lMU85K";
    [d setObject:link forKey:@"link"];
    
    // add name of the link param:
    NSString *linkName = @"Word du Jour on the iTunes App Store";
    [d setObject:linkName forKey:@"name"];
    
    // caption appears in small text below the link name:
    NSString *caption = @"Try it!";
    [d setObject:caption forKey:@"caption"];
    

    [facebook requestWithGraphPath:@"me/feed" andParams:d andHttpMethod:@"POST" andDelegate:self];

    
    NSString *confirmationMsg = [NSString stringWithFormat:@"Brag posted to your Facebook wall!\n\n%\"%@\"", msg];

    self.bragConfirmationView.message = confirmationMsg;
    
    [bragConfirmationView show];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
    return [facebook handleOpenURL:url];
}

- (void)saveFacebookSession {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:facebook.accessToken forKey:@"accessToken"];
    [userDefaults setObject:facebook.expirationDate forKey:@"expirationDate"];
    [userDefaults synchronize];
}

- (void)dealloc {
    [facebook release];
    facebook = nil;
    
    numGuesses = 0;

    [bragConfirmationView release];
    bragConfirmationView = nil;
    
    [super dealloc];
    
}

@end

