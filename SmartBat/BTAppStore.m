 //
//  BTAppStore.m
//  SmartBat
//
//  Created by kaka' on 13-6-8.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import "BTAppStore.h"

@implementation BTAppStore

-(BOOL)checkVersion{
    if((int)[[NSDate date] timeIntervalSince1970] - [BTGlobals sharedGlobals].lastCheckVersionDate < CHECK_VERSION_DURATION){
        return NO;
    }
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:APP_LOOKUP_URL]];
    [request setDelegate:self];
    [request startSynchronous];
    
    return YES;
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSString *localVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    NSLog(@"%@", localVersion);
    
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingAllowFragments error:&error];
    
    NSDictionary* results = [[json objectForKey:@"results"] objectAtIndex:0];
    
    NSString* lasterVersion = [results objectForKey:@"version"];
    trackViewUrl = [results objectForKey:@"trackViewUrl"];
    
    NSLog(@"%@, %@", lasterVersion, trackViewUrl);
    
    if([localVersion isEqual:lasterVersion]){
        //
    }else{
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"发现新版本！"
                                                      message:@""
                                                     delegate:self
                                            cancelButtonTitle:@"以后再说"
                                            otherButtonTitles:@"马上更新",nil];
        [av show];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex != [alertView cancelButtonIndex])
    {
        NSURL *url = [NSURL URLWithString:trackViewUrl];
        [[UIApplication sharedApplication] openURL:url];
    }
    
    [BTGlobals sharedGlobals].lastCheckVersionDate = (int)[[NSDate date] timeIntervalSince1970];
}

-(BOOL)gotoGrade{
    
}

@end
