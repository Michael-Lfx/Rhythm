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
    //如果距上次检查更新时刻，小于一个指定时间，退出
    if((int)[[NSDate date] timeIntervalSince1970] - [BTGlobals sharedGlobals].lastCheckVersionDate < CHECK_VERSION_DURATION){
        return NO;
    }
    
    //请求苹果接口查找版本信息
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:APP_LOOKUP_URL]];
    [request setDelegate:self];
    [request startSynchronous];
    
    return YES;
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    //拿到本地版本
    NSString *localVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    NSLog(@"%@", localVersion);
    
    //读取json数据
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingAllowFragments error:&error];
    
    NSDictionary* results = [[json objectForKey:@"results"] objectAtIndex:0];
    
    //最新发布版本
    NSString* lasterVersion = [results objectForKey:@"version"];
    //appstore地址
    trackViewUrl = [results objectForKey:@"trackViewUrl"];
    
    NSLog(@"%@, %@", lasterVersion, trackViewUrl);
    
    //记录此次检查时间
    [BTGlobals sharedGlobals].lastCheckVersionDate = (int)[[NSDate date] timeIntervalSince1970];
    
    if(![localVersion isEqual:lasterVersion]){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"New Version!", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"Later", nil) otherButtonTitles:NSLocalizedString(@"Update", nil), nil];
        //用来区分更新、评分两个窗口
        av.tag = 1;
        [av show];
    }
}

//button消失后调用
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSURL *url;
    
    if (alertView.tag == 1 && buttonIndex != [alertView cancelButtonIndex])
    {
        //更新
        url = [NSURL URLWithString:trackViewUrl];
    }else if (alertView.tag == 2 && buttonIndex != [alertView cancelButtonIndex]){
        //评分
        url = [NSURL URLWithString:@"http://www.baidu.com/"];
    }
    
    [[UIApplication sharedApplication] openURL:url];
}

-(BOOL)askGraed{
    //如果距离安装app还小于一个指定时间，或者已经弹出过评分窗口了，退出
    if(((int)[[NSDate date] timeIntervalSince1970] - [BTGlobals sharedGlobals].installDate < ASK_GRADE_DURATION) || [BTGlobals sharedGlobals].hasAskGrade == 1){
        
        return NO;
    }
    
    //标记已经弹出过评分窗口
    [BTGlobals sharedGlobals].hasAskGrade = 1;
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Please give me a rate", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"No", nil) otherButtonTitles:NSLocalizedString(@"Let's go", nil), nil];
    //区分
    av.tag = 2;
    [av show];

    return YES;
}

@end
