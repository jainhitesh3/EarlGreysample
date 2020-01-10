#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "GREYAction.h"
#import "GREYActionsShorthand.h"
#import "GREYHostBackgroundDistantObject+GREYApp.h"
#import "GREYMatchersShorthand.h"
#import "GREYAssertionBlock.h"
#import "GREYConfiguration.h"
#import "GREYHostApplicationDistantObject.h"
#import "GREYTestApplicationDistantObject.h"
#import "GREYErrorConstants.h"
#import "GREYFailureHandler.h"
#import "GREYFrameworkException.h"
#import "GREYDefines.h"
#import "GREYElementMatcherBlock.h"
#import "GREYMatcher.h"
#import "XCTestCase+GREYSystemAlertHandler.h"
#import "GREYAssertionDefines.h"
#import "GREYCondition.h"
#import "EarlGrey.h"
#import "GREYElementInteraction.h"
#import "GREYInteraction.h"
#import "GREYInteractionDataSource.h"
#import "GREYAllOf.h"
#import "GREYAnyOf.h"
#import "GREYMatchers.h"
#import "GREYAppStateTracker.h"
#import "GREYAppStateTrackerObject.h"
#import "GREYSyncAPI.h"
#import "GREYUIThreadExecutor.h"
#import "GREYConstants.h"
#import "GREYAssertion.h"
#import "GREYConfigKey.h"
#import "GREYBaseMatcher.h"
#import "GREYDescription.h"
#import "GREYHostBackgroundDistantObject.h"
#import "GREYAssertionDefinesPrivate.h"
#import "GREYAppState.h"
#import "GREYDiagnosable.h"
#import "GREYIdlingResource.h"

FOUNDATION_EXPORT double EarlGreyTestVersionNumber;
FOUNDATION_EXPORT const unsigned char EarlGreyTestVersionString[];

