//
// Copyright 2019 Google Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "GREYVisibilityChecker.h"

#import <CoreGraphics/CoreGraphics.h>

#import "NSObject+GREYCommon.h"
#import "UIView+GREYCommon.h"
#import "GREYFatalAsserts.h"
#import "GREYConstants.h"
#import "GREYLogger.h"
#import "CGGeometry+GREYUI.h"
#import "GREYQuickVisibilityChecker.h"
#import "GREYThoroughVisibilityChecker.h"
#import "GREYVisibilityCheckerCacheEntry.h"
#import "GREYVisibilityCheckerDuration.h"

static CFTimeInterval gVisibilityDuration = 0;

/**
 *  The minimum number of points that must be visible along with the activation point to consider an
 *  element visible. It is non-static to make it visible in tests.
 */
const NSUInteger kMinimumPointsVisibleForInteraction = 10;

/**
 *  Cache for storing recent visibility checks. This cache is invalidated on every runloop spin.
 */
static NSMapTable<NSString *, GREYVisibilityCheckerCacheEntry *> *gCache;

#pragma mark - GREYVisibilityChecker

@implementation GREYVisibilityChecker

+ (BOOL)isNotVisible:(id)element {
  return [self percentVisibleAreaOfElement:element] == 0;
}

+ (CGFloat)percentVisibleAreaOfElement:(id)element {
  if (!element) {
    return 0;
  }

  GREYVisibilityCheckerCacheEntry *cache = [self grey_cacheForElementCreateIfNonExistent:element];
  NSNumber *percentVisible = [cache visibleAreaPercent];
  if (percentVisible) {
    return [percentVisible floatValue];
  }

  CFTimeInterval startTime = CACurrentMediaTime();
  CGFloat result = [GREYThoroughVisibilityChecker percentVisibleAreaOfElement:element];
  gVisibilityDuration += CACurrentMediaTime() - startTime;
  cache.visibleAreaPercent = @(result);
  return result;
}

+ (CGPoint)visibleInteractionPointForElement:(id)element {
  CFTimeInterval startTime = CACurrentMediaTime();
  if (!element) {
    // Nil elements are not considered visible for interaction.
    return GREYCGPointNull;
  }

  GREYVisibilityCheckerCacheEntry *cache = [self grey_cacheForElementCreateIfNonExistent:element];
  NSValue *cachedPointValue = [cache visibleInteractionPoint];
  if (cachedPointValue) {
    return [cachedPointValue CGPointValue];
  }
  CGPoint result = [GREYThoroughVisibilityChecker visibleInteractionPointForElement:element];
  cache.visibleInteractionPoint = [NSValue valueWithCGPoint:result];
  gVisibilityDuration += CACurrentMediaTime() - startTime;
  return result;
}

+ (CGRect)rectEnclosingVisibleAreaOfElement:(id)element {
  CFTimeInterval startTime = CACurrentMediaTime();
  GREYVisibilityCheckerCacheEntry *cache = [self grey_cacheForElementCreateIfNonExistent:element];
  NSValue *rectValue = [cache rectEnclosingVisibleArea];
  if (rectValue) {
    return [rectValue CGRectValue];
  }
  CGRect visibleAreaRect =
      [GREYThoroughVisibilityChecker rectEnclosingVisibleAreaOfElement:element];
  cache.rectEnclosingVisibleArea = [NSValue valueWithCGRect:visibleAreaRect];
  gVisibilityDuration += CACurrentMediaTime() - startTime;
  return visibleAreaRect;
}

#pragma mark - Private

/**
 *  @return The cached key for an @c element.
 */
+ (NSString *)grey_keyForElement:(id)element {
  return [NSString stringWithFormat:@"%p", element];
}

/**
 *  Saves a cache @c entry for an @c element and adds it for invalidation on the next runloop drain.
 *
 *  @param entry   The cache entry to be saved.
 *  @param element The element to which the entry is associated.
 */
+ (void)grey_addCache:(GREYVisibilityCheckerCacheEntry *)entry forElement:(id)element {
  if (!gCache) {
    gCache = [NSMapTable strongToStrongObjectsMapTable];
  }

  // Get the pointer value and store it as a string.
  NSString *elementKey = [self grey_keyForElement:element];
  [gCache setObject:entry forKey:elementKey];

  // Set us up for invalidation on the next runloop drain.
  static BOOL pendingInvalidation = NO;
  if (!pendingInvalidation) {
    pendingInvalidation = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
      pendingInvalidation = NO;
      [GREYVisibilityChecker grey_invalidateCache];
    });
  }
}

/**
 *  Returns cached value for an @c element. Modifying the returned cache also modifies it in the
 *  backing store so any changes are visible next time cache is fetched for the same @c element,
 *  provided the cache is still valid.
 *
 *  @param element The element whose cache is being queried.
 *
 *  @return The cached stored under the given @c element.
 */
+ (GREYVisibilityCheckerCacheEntry *)grey_cacheForElementCreateIfNonExistent:(id)element {
  if (!element) {
    return nil;
  }
  GREYVisibilityCheckerCacheEntry *entry;
  if (gCache) {
    NSString *elementKey = [self grey_keyForElement:element];
    entry = [gCache objectForKey:elementKey];
  }

  if (!entry) {
    entry = [[GREYVisibilityCheckerCacheEntry alloc] init];
    [self grey_addCache:entry forElement:element];
  }
  return entry;
}

/**
 *  Invalidates the global cache of visibility checks.
 */
+ (void)grey_invalidateCache {
  [gCache removeAllObjects];
}

#pragma mark - Package Internal

+ (void)resetVisibilityImages {
  [GREYThoroughVisibilityChecker resetVisibilityImages];
}

+ (UIImage *)grey_lastActualBeforeImage {
  return [GREYThoroughVisibilityChecker lastActualBeforeImage];
}

+ (UIImage *)grey_lastActualAfterImage {
  return [GREYThoroughVisibilityChecker lastActualAfterImage];
}

+ (UIImage *)grey_lastExpectedAfterImage {
  return [GREYThoroughVisibilityChecker lastExpectedAfterImage];
}

@end

@implementation GREYVisibilityCheckerDuration

+ (CFTimeInterval)resetAndReturnTotalVisibilityCheckingTime {
  CFTimeInterval visibilityTime = gVisibilityDuration;
  gVisibilityDuration = 0;
  return visibilityTime;
}

@end
