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
        [BTGlobals sharedGlobals].lastCheckVersionDate = (int)[[NSDate date] timeIntervalSince1970];
        
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"New Version!", @"")
                                                      message:@""
                                                     delegate:self
                                            cancelButtonTitle:@"以后再说"
                                            otherButtonTitles:@"马上更新",nil];
        av.tag = 1;
        [av show];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSURL *url;
    
    if (alertView.tag == 1 && buttonIndex != [alertView cancelButtonIndex])
    {
        url = [NSURL URLWithString:trackViewUrl];
    }else if (alertView.tag == 2 && buttonIndex != [alertView cancelButtonIndex]){
        url = [NSURL URLWithString:@"http://www.baidu.com/"];
    }
    
    [[UIApplication sharedApplication] openURL:url];
}

-(BOOL)askGraed{
    if(((int)[[NSDate date] timeIntervalSince1970] - [BTGlobals sharedGlobals].installDate < ASK_GRADE_DURATION) || [BTGlobals sharedGlobals].hasAskGrade == 1){
        
        return NO;
    }
    
    [BTGlobals sharedGlobals].hasAskGrade = 1;
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"来都来了，评个分吧！"
                                                 message:@""
                                                delegate:self
                                       cancelButtonTitle:@"不了"
                                       otherButtonTitles:@"马上去",nil];
    av.tag = 2;
    [av show];

    return YES;
}

@end
