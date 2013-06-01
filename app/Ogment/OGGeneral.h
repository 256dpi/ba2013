//
//  Ogment.h
//  Ogment
//
//  Created by Joël Gähwiler on 19.04.13.
//  Copyright (c) 2013 256dpi. All rights reserved.
//

#pragma once

//#define OG_DEBUG 1

#define OG_TIMER_RESOLUTION 0.025

#ifdef OG_DEBUG

#define OG_GAME_TIME 300.0
#define OG_SELECTION_TIME 1.0
#define OG_FAKE_RESULT_TIME 1.0
#define OG_PAGE_MANIPULATION_TIME 3.0

#else

#define OG_GAME_TIME 120.0
#define OG_SELECTION_TIME 10
#define OG_FAKE_RESULT_TIME 15.0
#define OG_PAGE_MANIPULATION_TIME 25.0

#endif

typedef void (^Block)();

void delay_block(int64_t delayInSeconds, Block block);
