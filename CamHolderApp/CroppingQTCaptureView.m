//
//  CroppingQTCaptureView.m
//  CameraControl
//
//  Created by Heiko Behrens on 19.10.11.
//  Copyright 2011 BeamApp. All rights reserved.
//

#import "CroppingQTCaptureView.h"
#import "CHGeometryUtils.h"

@implementation CroppingQTCaptureView

@synthesize canSelectRect;

-(void)storeCurrentSelectionWithLocationInWindow:(NSPoint)location {
	NSPoint local = [self convertPoint:location fromView:nil];
	
	// width and height always positive
	NSRect r = NSRectFromPoints(ptMouseDown, local);
	
	currentSelectionInViewCoordinates = NSIntersectionRect(r, self.previewBounds);
	
	// look into free space due to aspect ratio
	r = NSIntersectionRect(r, self.previewBounds);
	r = NSOffsetRect(r, -self.previewBounds.origin.x, -self.previewBounds.origin.y);
	
	// convert to normalized coordinates [0..1]
	float fx = 1 / self.previewBounds.size.width;
	float fy = 1 / self.previewBounds.size.height;
	
	r.origin.x *= fx;
	r.origin.y *= fy;
	r.size.width *= fx;
	r.size.height *= fy;
	
	currentSelection = r;
}

-(void) mouseDown:(NSEvent *)theEvent {
	if(self.canSelectRect) {
		ptMouseDown =  [self convertPoint:theEvent.locationInWindow fromView:nil];
		if([self.delegate respondsToSelector:@selector(viewWillSelectRect:)])
			[(id<CroppingQTCaptureViewDelegate>)self.delegate viewWillSelectRect:self];
	}
	[super mouseDown:theEvent];
}

- (void)mouseUp:(NSEvent *)theEvent {
	if(self.canSelectRect) {
		[self storeCurrentSelectionWithLocationInWindow: theEvent.locationInWindow];
		if([self.delegate respondsToSelector:@selector(view:didSelectRect:)]) 
			[(id<CroppingQTCaptureViewDelegate>)self.delegate view:self didSelectRect:currentSelection];
	}
	[super mouseUp:theEvent];
}

- (void)mouseDragged:(NSEvent *)theEvent {
	if(self.canSelectRect) {
		[self storeCurrentSelectionWithLocationInWindow:theEvent.locationInWindow];
		if([self.delegate respondsToSelector:@selector(view:mightSelectRectInViewCoordinates:)]) {
			[(id<CroppingQTCaptureViewDelegate>)self.delegate view:self mightSelectRectInViewCoordinates:currentSelectionInViewCoordinates];
		}
	}
	[super mouseDragged:theEvent];
}
@end
