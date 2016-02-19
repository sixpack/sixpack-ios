//
//  SGSixpackExperiment.h
//  SixpackClient
//
//  Created by James Van-As on 10/10/13.
//  Copyright (c) 2013 SeatGeek Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AFHTTPSessionManager;

@interface SGSixpackExperiment : NSObject

//the experiment name
@property (strong) NSString *name;

//the list of possible alternatives
@property (strong) NSArray *alternatives;

//if forcedAlternative is set it will tell the server to choose this alternative
@property (strong) NSString *forcedAlternative;

//chosenAlternative is the alternative received from the sixpack server
@property (strong) NSString *chosenAlternative;

//the unique identifier of the client
@property (strong) NSString *clientID;

//the url for requesting the sixpack experiment
@property (strong) NSString *url;

//the network operation manager that will be handling communication
@property (weak) AFHTTPSessionManager *sessionManager;

//block to perform on successful receipt of a chosen alternative
@property (copy) void(^setupCompleteBlock)();

//timeout where if sixpack doesn't respond in then setupCompleteBlock will be called
@property (assign) NSTimeInterval setupCompleteBlockTimeout;

//block to perform on successful receipt of a chosen alternative
@property (assign) BOOL setupCompleteBlockCalled;

@end
