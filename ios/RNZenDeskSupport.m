//
//  RNZenDeskSupport.m
//
//  Created by Patrick O'Connor on 8/30/17.
//
#import <React/RCTUtils.h>
// RN < 0.40 suppoert
#if __has_include(<React/RCTBridge.h>)
#import <React/RCTConvert.h>
#else
#import "RCTConvert.h"
#endif

#import "RNZenDeskSupport.h"
#import <ZendeskSDK/ZendeskSDK.h>
#import <ZendeskProviderSDK/ZendeskProviderSDK.h>
#import <ZendeskCoreSDK/ZendeskCoreSDK.h>


@implementation RNZenDeskSupport

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(initialize:(NSDictionary *)config){
    NSString *appId = [RCTConvert NSString:config[@"appId"]];
    NSString *zendeskUrl = [RCTConvert NSString:config[@"zendeskUrl"]];
    NSString *clientId = [RCTConvert NSString:config[@"clientId"]];
    
    [ZDKZendesk initializeWithAppId:appId clientId:clientId zendeskUrl:zendeskUrl];
    [ZDKSupport initializeWithZendesk:[ZDKZendesk instance]];
}

RCT_EXPORT_METHOD(setupIdentity:(NSDictionary *)identity){
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *email = [RCTConvert NSString:identity[@"customerEmail"]];
        NSString *name = [RCTConvert NSString:identity[@"customerName"]];
        id<ZDKObjCIdentity> userIdentity = [[ZDKObjCAnonymous alloc] initWithName:name email:email];
        [[ZDKZendesk instance] setIdentity:userIdentity];
        
    });
}

RCT_EXPORT_METHOD(showHelpCenterWithOptions:(NSDictionary *)options) {
    dispatch_async(dispatch_get_main_queue(), ^{
        ZDKHelpCenterUiConfiguration * hcConfig = [ZDKHelpCenterUiConfiguration new];
        hcConfig.showContactOptionsOnEmptySearch = [RCTConvert BOOL:options[@"hideContactSupport"]];
        UIViewController *helpCenter = [ZDKHelpCenterUi buildHelpCenterOverviewUiWithConfigs:@[hcConfig]];
        helpCenter.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: options[@"localizedDismissButtonTitle"] ?: @"Close"
                                                                                           style: UIBarButtonItemStylePlain
                                                                                          target: self
                                                                                          action: @selector(dismissZendeskUI)];
        UINavigationController *helpCenterNav = [[UINavigationController alloc] initWithRootViewController: helpCenter];

        [RCTPresentedViewController() presentViewController:helpCenterNav animated:YES completion:nil];
    });
}

- (void) doNothing {
    
}

- (void) dismissZendeskUI {
    [RCTPresentedViewController() dismissViewControllerAnimated:YES completion:^{}];
}



RCT_EXPORT_METHOD(showCategoriesWithOptions:(NSArray *)categories options:(NSDictionary *)options) {
    dispatch_async(dispatch_get_main_queue(), ^{
        ZDKHelpCenterUiConfiguration * hcConfig = [ZDKHelpCenterUiConfiguration new];
        hcConfig.showContactOptionsOnEmptySearch = [RCTConvert BOOL:options[@"hideContactSupport"]];
        hcConfig.groupType = ZDKHelpCenterOverviewGroupTypeCategory;
        hcConfig.groupIds =categories;
        UIViewController *helpCenter = [ZDKHelpCenterUi buildHelpCenterOverviewUiWithConfigs:@[hcConfig]];
        helpCenter.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: options[@"localizedDismissButtonTitle"] ?: @"Close"
                                                                                           style: UIBarButtonItemStylePlain
                                                                                          target: self
                                                                                          action: @selector(dismissZendeskUI)];
        UINavigationController *helpCenterNav = [[UINavigationController alloc] initWithRootViewController: helpCenter];
        [RCTPresentedViewController() presentViewController:helpCenterNav animated:YES completion:nil];
       
    });
}

RCT_EXPORT_METHOD(showSectionsWithOptions:(NSArray *)sections options:(NSDictionary *)options) {
    dispatch_async(dispatch_get_main_queue(), ^{
        ZDKHelpCenterUiConfiguration * hcConfig = [ZDKHelpCenterUiConfiguration new];
        hcConfig.showContactOptionsOnEmptySearch = [RCTConvert BOOL:options[@"hideContactSupport"]];
        hcConfig.groupType = ZDKHelpCenterOverviewGroupTypeSection;
        hcConfig.groupIds = sections;
        UIViewController *helpCenter = [ZDKHelpCenterUi buildHelpCenterOverviewUiWithConfigs:@[hcConfig]];
        helpCenter.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: options[@"localizedDismissButtonTitle"] ?: @"Close"
                                                                                           style: UIBarButtonItemStylePlain
                                                                                          target: self
                                                                                          action: @selector(dismissZendeskUI)];
        UINavigationController *helpCenterNav = [[UINavigationController alloc] initWithRootViewController: helpCenter];
        [RCTPresentedViewController() presentViewController:helpCenterNav animated:YES completion:nil];
    });
}

RCT_EXPORT_METHOD(showLabelsWithOptions:(NSArray *)labels options:(NSDictionary *)options) {
    dispatch_async(dispatch_get_main_queue(), ^{
        ZDKHelpCenterUiConfiguration * hcConfig = [ZDKHelpCenterUiConfiguration new];
        hcConfig.showContactOptionsOnEmptySearch = [RCTConvert BOOL:options[@"hideContactSupport"]];
        hcConfig.labels = labels;
        UIViewController *helpCenter = [ZDKHelpCenterUi buildHelpCenterOverviewUiWithConfigs:@[hcConfig]];
        helpCenter.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: options[@"localizedDismissButtonTitle"] ?: @"Close"
                                                                                           style: UIBarButtonItemStylePlain
                                                                                          target: self
                                                                                          action: @selector(dismissZendeskUI)];
        UINavigationController *helpCenterNav = [[UINavigationController alloc] initWithRootViewController: helpCenter];
        [RCTPresentedViewController() presentViewController:helpCenterNav animated:YES completion:nil];
       
    });
}

RCT_EXPORT_METHOD(showHelpCenter) {
    [self showHelpCenterWithOptions:nil];
}

RCT_EXPORT_METHOD(showCategories:(NSArray *)categories) {
    [self showCategoriesWithOptions:categories options:nil];
}

RCT_EXPORT_METHOD(showSections:(NSArray *)sections) {
    [self showSectionsWithOptions:sections options:nil];
}

RCT_EXPORT_METHOD(showLabels:(NSArray *)labels) {
    [self showLabelsWithOptions:labels options:nil];
}

RCT_EXPORT_METHOD(callSupport:(NSDictionary *)customFields) {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableArray *fields = [[NSMutableArray alloc] init];
        for (NSString* key in customFields) {
            id value = [customFields objectForKey:key];
            [fields addObject: [[ZDKCustomField alloc] initWithFieldId:@(key.integerValue) andValue:value]];
        }
        ZDKRequestUiConfiguration * config = [[ZDKRequestUiConfiguration alloc] init];
        config.fields = fields;
        UIViewController *requestScreen = [ZDKRequestUi buildRequestUiWith:@[config]];

        UINavigationController *requestScreenNav = [[UINavigationController alloc] initWithRootViewController: requestScreen];
        [RCTPresentedViewController() presentViewController:requestScreenNav animated:YES completion:nil];
    });
}

RCT_EXPORT_METHOD(supportHistory){
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *requestListController = [ZDKRequestUi buildRequestList];
        requestListController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: @"Back"
                                                                                                                                                                                style: UIBarButtonItemStylePlain
                                                                                                                                                                               target: self
                                                                                                                                                                               action: @selector(dismissZendeskUI)];
UINavigationController *requestListControllerNav = [[UINavigationController alloc] initWithRootViewController: requestListController];
[RCTPresentedViewController() presentViewController:requestListControllerNav animated:YES completion:nil];
    });
}

RCT_EXPORT_METHOD(createRequest:(NSDictionary *)request
                  createRequestWithResolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    
    ZDKCreateRequest *zdRequest = [ZDKCreateRequest new];
    NSString *subject = [RCTConvert NSString:request[@"subject"]];
    if (subject != nil) {
        zdRequest.subject = subject;
    }
    NSString *requestDescription = [RCTConvert NSString:request[@"requestDescription"]];
    if (requestDescription != nil) {
        zdRequest.requestDescription = requestDescription;
    }
    NSArray *tags = [RCTConvert NSArray:request[@"tags"]];
    if (tags != nil) {
        zdRequest.tags = tags;
    }
    
    ZDKRequestProvider *provider = [[ZDKRequestProvider alloc] init];
    [provider createRequest:zdRequest withCallback:^(id result, NSError *error) {
        if (error) {
            // Handle the error
            reject(@"No Ticket", @"Failed to create ticket", error);
            // Log the error
//            [ZDKLogger e:error.description];
            
        } else {
            // Handle the success
            ZDKDispatcherResponse * payload = result;
            NSString *data = [[NSString alloc] initWithData:payload.data encoding:NSUTF8StringEncoding];
            
            // Deserialize the data JSON string to an NSDictionary
            NSError *jsonError;
            NSData *objectData = [data dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&jsonError];
            resolve(json);
        }
    }];
}
@end
