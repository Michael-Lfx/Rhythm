//
//  BTAppStore.h
//  SmartBat
//
//  Created by kaka' on 13-6-8.
//  Copyright (c) 2013年 kaka'. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "BTGlobals.h"
#import "BTConstants.h"

@interface BTAppStore : NSObject<UIAlertViewDelegate>{
    NSString* trackViewUrl;
}

-(BOOL)checkVersion;
-(BOOL)askGraed;

@end
