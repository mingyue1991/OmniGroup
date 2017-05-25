// Copyright 2010-2016 Omni Development, Inc. All rights reserved.
//
// This software may only be used and reproduced according to the
// terms in the file OmniSourceLicense.html, which should be
// distributed with this project and can also be found at
// <http://www.omnigroup.com/developer/sourcecode/sourcelicense/>.
//
// $Id$

#import <OmniUI/OmniUI.h>

@interface OUIInspectorNavigationController : OUINavigationController <OUIInspectorPaneContaining>

/// Pops the nav stack to the top most OUIInspectorPane that is appropriate for the inspectedObjects, ensuring that all OUIInspectorPane's under it are also appropriate.
- (void)popToAppropriatePane;

@end