/*
 Copyright (c) 2010 Robert Chin
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

// Based on RCSwitch.m
// Modified by Paul Chote 2012-01-02 to hardcode notification center look

#import "NCSwitch.h"
#import <QuartzCore/QuartzCore.h>

@interface NCSwitch ()
- (void)performSwitchToPercent:(float)toPercent;
@end

@implementation NCSwitch

- (id)initWithFrame:(CGRect)aRect thumbImage: (UIImage *)image
{
	if((self = [super initWithFrame:aRect])){
		animationDuration = 0.25;
    	self.contentMode = UIViewContentModeRedraw;

        trackImage = [[[UIImage imageWithContentsOfFile:@"/System/Library/WeeAppPlugins/StocksWeeApp.bundle/WeeAppBackground.png"] resizableImageWithCapInsets: UIEdgeInsetsMake(4, 4, 4, 4)] retain];
        knobImage = [image retain];
        knobWidth = knobImage.size.width;
    	self.opaque = NO;

    	onText = [UILabel new];
    	onText.text = [[NSBundle bundleForClass:[UISwitch class]] localizedStringForKey:@"ON" value:nil table:nil];
    	onText.textColor = [UIColor whiteColor];
    	onText.font = [UIFont boldSystemFontOfSize:16];
        onText.shadowOffset = CGSizeMake(0.0, -0.5);
    	onText.shadowColor = [UIColor colorWithWhite:0.2 alpha:0.5];

    	offText = [UILabel new];
    	offText.text = [[NSBundle bundleForClass:[UISwitch class]] localizedStringForKey:@"OFF" value:nil table:nil];
    	offText.textColor = [UIColor colorWithWhite:0.7 alpha:0.5];
    	offText.font = [UIFont boldSystemFontOfSize:16];
	}
	return self;
}

- (void)dealloc
{
	[knobImage release];
	[trackImage release];
	[onText release];
	[offText release];
	[super dealloc];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
	CGRect boundsRect = self.bounds;

	CGContextSaveGState(context);
	UIGraphicsPushContext(context);
	[trackImage drawInRect: boundsRect];
	UIGraphicsPopContext();
	CGContextRestoreGState(context);

	float width = boundsRect.size.width;
	float drawPercent = percent;
	if(((width - knobWidth) * drawPercent) < 3)
		drawPercent = 0.0;
	if(((width - knobWidth) * drawPercent) > (width - knobWidth - 3))
		drawPercent = 1.0;
	
	if(endDate){
		NSTimeInterval interval = [endDate timeIntervalSinceNow];
		if(interval < 0.0){
			[endDate release];
			endDate = nil;
		} else {
			if(percent == 1.0)
				drawPercent = cosf((interval / animationDuration) * (M_PI / 2.0));
			else
				drawPercent = 1.0 - cosf((interval / animationDuration) * (M_PI / 2.0));
			[self performSelector:@selector(setNeedsDisplay) withObject:nil afterDelay:0.0];
		}
	}
    {
		CGContextSaveGState(context);
		UIGraphicsPushContext(context);
            CGPoint location = boundsRect.origin;
            float offset = drawPercent * (boundsRect.size.width - knobWidth);
            float buttonLeft = location.x + roundf(offset);
            float trackWidth = (boundsRect.size.width - knobWidth);
		
		{
            [trackImage drawInRect:CGRectMake(location.x, location.y, buttonLeft + [knobImage size].width/2, boundsRect.size.height)];

	    	{
    			CGRect textRect = [self bounds];
    			textRect.origin.x += 10 + (offset - trackWidth);
    			[onText drawTextInRect:textRect];	
    		}
		
    		{
    			CGRect textRect = [self bounds];
    			textRect.origin.x += -10 + (offset + trackWidth);
    			[offText drawTextInRect:textRect];
    		}
		}
		UIGraphicsPopContext();
		CGContextRestoreGState(context);
		
		CGContextSaveGState(context);
		UIGraphicsPushContext(context);

		{
			CGContextScaleCTM(context, 1.0, -1.0);
			CGContextTranslateCTM(context, 0.0, -boundsRect.size.height);		    
			CGRect drawOnRect = CGRectMake(buttonLeft, location.y, [knobImage size].width, [knobImage size].height);
			CGContextDrawImage(context, drawOnRect, [knobImage CGImage]);
		}
		UIGraphicsPopContext();
		CGContextRestoreGState(context);
	}
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	self.highlighted = YES;
	oldPercent = percent;
	[endDate release];
	endDate = nil;
	mustFlip = YES;
	[self setNeedsDisplay];
	[self sendActionsForControlEvents:UIControlEventTouchDown];
	return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint point = [touch locationInView:self];
	percent = (point.x - knobWidth / 2.0) / (self.bounds.size.width - knobWidth);
	if(percent < 0.0)
		percent = 0.0;
	if(percent > 1.0)
		percent = 1.0;
	if((oldPercent < 0.25 && percent > 0.5) || (oldPercent > 0.75 && percent < 0.5))
		mustFlip = NO;
	[self setNeedsDisplay];
	[self sendActionsForControlEvents:UIControlEventTouchDragInside];
	return YES;
}

- (void)finishEvent
{
	self.highlighted = NO;
	[endDate release];
	endDate = nil;
	float toPercent = roundf(1.0 - oldPercent);
	if(!mustFlip){
		if(oldPercent < 0.25){
			if(percent > 0.5)
				toPercent = 1.0;
			else
				toPercent = 0.0;
		}
		if(oldPercent > 0.75){
			if(percent < 0.5)
				toPercent = 0.0;
			else
				toPercent = 1.0;
		}
	}
	[self performSwitchToPercent:toPercent];
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
	[self finishEvent];
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	[self finishEvent];
}

- (BOOL)isOn
{
	return percent > 0.5;
}

- (void)setOn:(BOOL)aBool
{
	[self setOn:aBool animated:NO];
}

- (void)setOn:(BOOL)aBool animated:(BOOL)animated
{
	if(animated)
	{
		float toPercent = aBool ? 1.0 : 0.0;
		if((percent < 0.5 && aBool) || (percent > 0.5 && !aBool))
			[self performSwitchToPercent:toPercent];
	}
	else
	{
		percent = aBool ? 1.0 : 0.0;
		[self setNeedsDisplay];
		[self sendActionsForControlEvents:UIControlEventValueChanged];
	}
}

- (void)performSwitchToPercent:(float)toPercent
{
	[endDate release];
	endDate = [[NSDate dateWithTimeIntervalSinceNow:fabsf(percent - toPercent) * animationDuration] retain];
	percent = toPercent;
	[self setNeedsDisplay];
	[self sendActionsForControlEvents:UIControlEventValueChanged];
	[self sendActionsForControlEvents:UIControlEventTouchUpInside];
}

@end
