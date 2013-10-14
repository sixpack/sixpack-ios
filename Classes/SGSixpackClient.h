//
//  SGSixpackClient.h
//  SixpackClient
//
//  Created by James Van-As on 9/10/13.
//  Copyright (c) 2013 SeatGeek Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AFHTTPRequestOperationManager;

@interface SGSixpackClient : NSObject

@property (strong) AFHTTPRequestOperationManager *operationManager;

- (void)connectToHost:(NSString *)url;

- (void)setupExperiment:(NSString *)experiment
           alternatives:(NSArray *)alternatives
            forceChoice:(NSString *)forcedChoice;

- (void)participateIn:(NSString *)experiment
             onChoose:(void(^)(NSString *chosenAlternative))block;

- (void)convert:(NSString *)experiment;

@end