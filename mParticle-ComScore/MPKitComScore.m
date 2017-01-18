//
//  MPKitComScore.m
//
//  Copyright 2016 mParticle, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "MPKitComScore.h"
#import "MPEvent.h"
#import "mParticle.h"
#import "MPKitRegister.h"
#if defined(__has_include) && __has_include(<ComScore/ComScore.h>)
#import <ComScore/ComScore.h>
#else
#import "ComScore.h"
#endif

typedef NS_ENUM(NSUInteger, MPcomScoreProduct) {
    MPcomScoreProductDirect = 1,
    MPcomScoreProductEnterprise
};

NSString *const ecsCustomerC2 = @"CustomerC2Value";
NSString *const ecsSecret = @"PublisherSecret";
NSString *const ecsAutoUpdateMode = @"autoUpdateMode";
NSString *const ecsAutoUpdateInterval = @"autoUpdateInterval";
NSString *const escAppName = @"appName";
NSString *const escProduct = @"product";
NSString *const ecsPartnerId = @"partnerId";

@interface MPKitComScore()

@property (nonatomic, unsafe_unretained) MPcomScoreProduct product;

@end


@implementation MPKitComScore

+ (NSNumber *)kitCode {
    return @39;
}

+ (void)load {
    MPKitRegister *kitRegister = [[MPKitRegister alloc] initWithName:@"comScore" className:@"MPKitComScore" startImmediately:YES];
    [MParticle registerExtension:kitRegister];
}

- (void)setupWithConfiguration:(NSDictionary *)configuration {
    
    SCORPublisherConfiguration *publisherConfig = [SCORPublisherConfiguration publisherConfigurationWithBuilderBlock:^(SCORPublisherConfigurationBuilder *builder) {
        
        builder.publisherId = configuration[ecsCustomerC2];
        builder.publisherSecret = configuration[ecsSecret];

        builder.usagePropertiesAutoUpdateMode = SCORUsagePropertiesAutoUpdateModeForegroundOnly;
        builder.usagePropertiesAutoUpdateInterval = [configuration[ecsAutoUpdateInterval] intValue];

        builder.secureTransmission = YES;

        if ([[configuration[ecsAutoUpdateMode] lowercaseString] isEqualToString:@"foreback"]) {
            builder.usagePropertiesAutoUpdateMode = SCORUsagePropertiesAutoUpdateModeForegroundAndBackground;
        }
        
        if (configuration[escAppName]) {
            builder.applicationName = configuration[escAppName];
        }
    }];
    [[SCORAnalytics configuration] addClientWithConfiguration:publisherConfig];
    
    SCORPartnerConfiguration *partnerConfig = [SCORPartnerConfiguration partnerConfigurationWithBuilderBlock:^(SCORPartnerConfigurationBuilder *builder) {
        builder.partnerId = configuration[ecsPartnerId];
    }];
    [[SCORAnalytics configuration] addClientWithConfiguration:partnerConfig];
    [SCORAnalytics start];
    
    if (configuration[escProduct]) {
        self.product = [configuration[escProduct] isEqualToString:@"enterprise"] ? MPcomScoreProductEnterprise : MPcomScoreProductDirect;
    }
}

#pragma mark Private methods
- (BOOL)isValidConfiguration:(NSDictionary *)configuration {
    NSString *customerC2 = configuration[ecsCustomerC2];
    NSString *secret = configuration[ecsSecret];

    BOOL validConfiguration = customerC2 != nil && (customerC2.length > 0) &&
                              secret != nil && (secret.length > 0);

    return validConfiguration;
}

- (NSDictionary *)convertAllValuesToString:(NSDictionary *)originalDictionary {
    NSMutableDictionary *convertedDictionary = [[NSMutableDictionary alloc] initWithCapacity:originalDictionary.count];
    NSEnumerator *originalEnumerator = [originalDictionary keyEnumerator];
    NSString *key;
    id value;
    Class NSStringClass = [NSString class];

    while ((key = [originalEnumerator nextObject])) {
        value = originalDictionary[key];

        if ([value isKindOfClass:NSStringClass]) {
            convertedDictionary[key] = value;
        } else {
            convertedDictionary[key] = [NSString stringWithFormat:@"%@", value];
        }
    }

    return convertedDictionary;
}

#pragma mark MPKitInstanceProtocol methods
- (instancetype)initWithConfiguration:(NSDictionary *)configuration startImmediately:(BOOL)startImmediately {
    self = [super init];
    if (!self || ![self isValidConfiguration:configuration]) {
        return nil;
    }

    self.product = MPcomScoreProductDirect;

    [self setupWithConfiguration:configuration];

    _configuration = configuration;
    _started = startImmediately;

    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *userInfo = @{mParticleKitInstanceKey:[[self class] kitCode]};

        [[NSNotificationCenter defaultCenter] postNotificationName:mParticleKitDidBecomeActiveNotification
                                                            object:nil
                                                          userInfo:userInfo];
    });

    return self;
}

- (MPKitExecStatus *)beginSession {
    [SCORAnalytics notifyUxActive];

    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceComScore) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (MPKitExecStatus *)endSession {
    [SCORAnalytics notifyUxInactive];

    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceComScore) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (MPKitExecStatus *)logEvent:(MPEvent *)event {
    MPKitExecStatus *execStatus;

    if (self.product != MPcomScoreProductEnterprise) {
        execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceComScore) returnCode:MPKitReturnCodeIncorrectProductVersion];
        return execStatus;
    }

    if (event.type == MPEventTypeNavigation) {
        return [self logScreen:event];
    } else {
        NSMutableDictionary *labelsDictionary = [@{@"name":event.name} mutableCopy];
        if (event.info) {
            [labelsDictionary addEntriesFromDictionary:[self convertAllValuesToString:event.info]];
        }

        [SCORAnalytics notifyHiddenEventWithLabels:labelsDictionary];

        execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceComScore) returnCode:MPKitReturnCodeSuccess];
        return execStatus;
    }
}

- (MPKitExecStatus *)logScreen:(MPEvent *)event {
    MPKitExecStatus *execStatus;

    if (self.product != MPcomScoreProductEnterprise) {
        execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceComScore) returnCode:MPKitReturnCodeIncorrectProductVersion];
        return execStatus;
    }

    NSMutableDictionary *labelsDictionary = [@{@"name":event.name} mutableCopy];
    if (event.info) {
        [labelsDictionary addEntriesFromDictionary:[self convertAllValuesToString:event.info]];
    }

    [SCORAnalytics notifyViewEventWithLabels:labelsDictionary];

    execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceComScore) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (MPKitExecStatus *)setDebugMode:(BOOL)debugMode {
    [SCORAnalytics setLogLevel:SCORLogLevelDebug];

    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceComScore) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (MPKitExecStatus *)setOptOut:(BOOL)optOut {
    if (optOut) {
        [[SCORAnalytics configuration] disable];
    }

    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceComScore) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (MPKitExecStatus *)setUserAttribute:(NSString *)key value:(NSString *)value {
    MPKitExecStatus *execStatus;

    if (self.product != MPcomScoreProductEnterprise) {
        execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceComScore) returnCode:MPKitReturnCodeIncorrectProductVersion];
        return execStatus;
    }

    if (value != nil) {
        [[SCORAnalytics configuration] setPersistentLabelWithName:key value:value];
    }

    execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceComScore) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (MPKitExecStatus *)setUserTag:(NSString *)tag {
    MPKitExecStatus *execStatus;

    if (self.product != MPcomScoreProductEnterprise) {
        execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceComScore) returnCode:MPKitReturnCodeIncorrectProductVersion];
        return execStatus;
    }

    [[SCORAnalytics configuration] setPersistentLabelWithName:tag value:@""];

    execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceComScore) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

@end
