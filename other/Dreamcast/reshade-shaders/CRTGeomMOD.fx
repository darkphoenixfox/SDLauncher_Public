#include "ReShade.fxh"

/* COMPATIBILITY
   - HLSL compilers
   - Cg   compilers
*/


/* 
	CRTGeomMOD v3.2 (Demul Special Version 2020-21-04) Shader customized and enhanced by Ducon2016 and Houb
	http://www.emuline.org/topic/1420-shader-crt-multifonction-kick-ass-looking-games/
*/


/*
    CRT-interlaced

    Copyright (C) 2010-2012 cgwg, Themaister and DOLLS

    This program is free software; you can redistribute it and/or modify it
    under the terms of the GNU General Public License as published by the Free
    Software Foundation; either version 2 of the License, or (at your option)
    any later version.

    (cgwg gave their consent to have the original version of this shader
    distributed under the GPL in this message:

        http://board.byuu.org/viewtopic.php?p=26075#p26075

        "Feel free to distribute my shaders under the GPL. After all, the
        barrel distortion code was taken from the Curvature shader, which is
        under the GPL."
    )
	This shader variant is pre-configured with screen curvature
*/


uniform bool CRT_EFFECT <
	ui_label = "CRT EFFECT";
	ui_tooltip = "To enable or not the CRT effect";
> = true;

uniform int aperture_type <
	ui_type = "combo";
	ui_items = " Simulated Aperture (Green/Magenta) \0 Dot-Mask Texture 1x1 \0 Dot-Mask Texture 2x2 \0";
	ui_label = "Aperture Mask Type";
> = 2;

uniform float2 texture_size <
	ui_type = "inp";
	ui_label = "Set The Simulated Texture Resolution X/Y (pixels)";
	ui_tooltip = "This is the native low resolution of the game used to build the scanline effect (0.0 = Not Defined)";
> = float2(320.0, 240.0);

uniform float2 buffer_offset <
	ui_type = "drag";
	ui_min = -5.0f;
	ui_max = 5.0f;
	ui_step = 0.1f;
	ui_label = "Offset Against The Buffer X/Y (pixels)";
	ui_tooltip = "Allows to set a small offset on the effect needed sometime to be perfectly match the game texture";
> = float2(0.0, 0.0);

uniform float dotmask <
	ui_type = "drag";
	ui_min = 0.1f;
	ui_max = 0.9f;
	ui_step = 0.01f;
	ui_label = "Dot-Mask Strength";
	ui_category = "CRT Advanced Settings";
	ui_category_closed = true;
> = 0.33f;

uniform float sharper <
	ui_type = "slider";
	ui_min = 1.0f;
	ui_max = 4.0f;
	ui_step = 0.1f;
	ui_label = "Sharpness";
	ui_category = "CRT Advanced Settings";
> = 2.0f;

uniform bool OVERSAMPLE <
	ui_label = "OVERSAMPLE";
	ui_tooltip = "Enable 3x oversampling of the beam profile (improves moire effect caused by scanlines + curvature)";
	ui_category = "CRT Advanced Settings";
> = true;

uniform float ovs_boost <
	ui_type = "slider";
	ui_min = 1.0f;
	ui_max = 3.0f;
	ui_step = 0.01f;
	ui_label = "Oversample Booster";
	ui_tooltip = "Attempts to reduce even more the moire effect but kills the pixel aspect";
	ui_category = "CRT Advanced Settings";
> = 1.0f;

uniform float lum <
	ui_type = "slider";
	ui_min = 0.01f;
	ui_max = 1.0f;
	ui_step = 0.01f;
	ui_label = "Luminance Boost";
	ui_category = "CRT Advanced Settings";
> = 0.88f;

uniform float CRTgamma <
	ui_type = "slider";
	ui_min  = 0.1f;
	ui_max = 5.0f;
	ui_step = 0.01f;
	ui_label = "Target Gamma";
	ui_category = "CRT Advanced Settings";
> = 2.4f;

uniform float monitorgamma <
	ui_type = "slider";
	ui_min = 0.1f;
	ui_max = 5.0f;
	ui_step = 0.01f;
	ui_label = "Monitor Gamma";
	ui_category = "CRT Advanced Settings";
> = 2.2f;

uniform float R <
	ui_type = "slider";
	ui_min = 0.0f;
	ui_max = 10.0f;
	ui_step = 0.1f;
	ui_label = "Curvature Radius";
	ui_category = "CRT Advanced Settings";
> = 2.9f;

uniform float d <
	ui_type = "slider";
	ui_min = 0.1f;
	ui_max = 3.0f;
	ui_step = 0.1f;
	ui_label =  "Distance";
	ui_category = "CRT Advanced Settings";
> = 2.7f;

uniform float2 tilt <
	ui_type = "slider";
	ui_min = -0.5f;
	ui_max = 0.5f;
	ui_step = 0.01f;
	ui_label = "Tilt X/Y";
	ui_category = "CRT Advanced Settings";
> = float2(0.0, 0.0);

uniform float cornersize <
	ui_type = "slider";
	ui_min = 0.0f;
	ui_max = 0.1f;
	ui_step = 0.001f;
	ui_label = "Corner Size";
	ui_category = "CRT Advanced Settings";
> = 0.01f;

uniform float cornersmooth <
	ui_type = "slider";
	ui_min = 10.0f;
	ui_max = 300.0f;
	ui_step = 10.0f;
	ui_label = "Corner Smoothness";
	ui_category = "CRT Advanced Settings";
> = 120.0f;

uniform bool CURVATURE <
	ui_label = "CURVATURE";
	ui_tooltip = "To enable or not the screen curvature";
> = true;

uniform float2 aspect_ratio <
	ui_type = "slider";
	ui_min = 0.1f;
	ui_max = 4.0f;
	ui_step = 0.01f;
	ui_label = "Manual Aspect Ratio Adjustement X/Y (1.0 = original size)";
> = float2(1.0, 1.0);

/*
uniform int2 inp_video_size <
	ui_type = "input";
	ui_label = "Input Image Resolution X/Y (pixels)";
	ui_tooltip = "This is the resolution of the image in the screen frame buffer (0 = full buffer)";
> = int2(0, 0);
*/

uniform float resize_adjust <
	ui_type = "slider";
	ui_min = 0.000f;
	ui_max = 4.000f;
	ui_step = 0.001f;
	ui_label = "Resize Ratio Adjustement";
	ui_tooltip = "Adjust how the game is resized depending of the display resolution (Ratio locked from center)";
> = 1.000f;

uniform float resize_ratio <
	ui_type = "slider";
	ui_min = 0.000f;
	ui_max = 4.000f;
	ui_step = 0.001f;
//	ui_type = "combo";
//	ui_items = " Simple Rezize From Top-Left Corner \0 32:9 Locked From Center \0 21:9 Locked From Center \0 16:9 Locked From Center \0 15:9 Locked From Center \0 16:10 Locked From Center \0 4:3 Locked From Center \0 5:4 Locked From Center \0 1:1 Locked From Center \0 4:5 Locked From Center \0 3:4 Locked From Center \0 9:16 Locked From Center \0";
	ui_label = "!DON'T TOUCH! Resize Ratio";
	ui_tooltip = "Select how the game is resized depending of the display resolution (Ratio locked from center)";
	ui_category = "Display Advanced Settings";
	ui_category_closed = true;
> = 0.000f;

uniform float inp_screen_ratio <
	ui_type = "slider";
	ui_min = 0.100f;
	ui_max = 4.000f;
	ui_step = 0.001f;
//	ui_type = "combo";
//	ui_items = " Auto Detection \0 32:9 Screen \0 21:9 Screen \0 16:9 Screen \0 15:9 Screen \0 16:10 Screen \0 4:3 Screen \0 5:4 Screen \0 1:1 Screen \0 4:5 Screen \0 3:4 Screen \0 9:16 Display \0";
	ui_label = "!DON'T TOUCH! Simulated Screen Ratio";
	ui_category = "Display Advanced Settings";
> = 0.000f;

uniform float inp_game_ratio <
	ui_type = "slider";
	ui_min = 0.100f;
	ui_max = 4.000f;
	ui_step = 0.001f;
//	ui_type = "combo";
//	ui_items = " Auto Detection \0 32:9 Display \0 21:9 Display \0 16:9 Display \0 15:9 Display \0 16:10 Display \0 4:3 Display \0 5:4 Display \0 1:1 Display \0 4:5 Display \0 3:4 Display \0 9:16 Display \0";
	ui_label = "!DON'T TOUCH! Simulated Game Ratio";
	ui_category = "Display Advanced Settings";
> = 0.000f;

uniform bool AUTO_ROTATED <
	ui_label = "!DON'T TOUCH! AUTO ROTATED";
	ui_tooltip = "If the game display is already auto-rotated";
	ui_category = "Display Advanced Settings";
> = false;

uniform bool ROTATED_180<
	ui_label = "ROTATE 180°";
	ui_tooltip = "To rotate the display (180°)";
	ui_category = "Display Advanced Settings";
> = false;

uniform bool ROTATED <
	ui_label = "ROTATE 90°CCW";
	ui_tooltip = "Rotate the display 90° CCW (Portrait to Landscape)";
> = false;

uniform bool VERTICAL_SCANLINES <
	ui_label = "VERTICAL SCANLINES";
	ui_tooltip = "To rotate the scanlines effect";
> = false;

uniform bool BLOOM <
	ui_label = "BLOOM";
	ui_tooltip = "To Enable Bloom Effect";
> = true;

uniform float BloomBlurOffset <
	ui_type = "slider";
	ui_min = 1.0f;
	ui_max = 2.0f;
	ui_step = 0.01f;
	ui_label = "Bloom Blur Offset";
	ui_tooltip = "Additional adjustment for the blur radius. Values less than 1.00 will reduce the radius.";
	ui_category = "Bloom Advanced Settings";
	ui_category_closed = true;
> = 1.6f;

uniform float BloomStrength <
	ui_type = "slider";
	ui_min = 0.0f;
	ui_max = 1.0f;
	ui_step = 0.01f;
	ui_label = "Bloom Strength";
	ui_tooltip = "Adjusts the strength of the effect.";
	ui_category = "Bloom Advanced Settings";
> = 0.16f;

uniform float BloomContrast <
	ui_type = "slider";
	ui_min = 0.00;
	ui_max = 1.00;
	ui_step = 0.01f;
	ui_label = "Bloom Contrast";
	ui_tooltip = "Adjusts the contrast of the effect.";
	ui_category = "Bloom Advanced Settings";
> = 0.66f;

uniform bool USE_OVERLAY <
	ui_label = "SCREEN OVERLAY";
	ui_tooltip = "To add a screen overlay over the CRT display area";
> = true;

uniform bool USE_FRAME <
	ui_label = "SCREEN FRAME";
	ui_tooltip = "To add a screen frame-overlay over the CRT display area";
> = false;

uniform bool USE_BACKGROUND <
	ui_label = "BACKGROUND IMAGE";
	ui_tooltip = "To display a full image behind the display";
> = true;

uniform bool USE_BEZEL <
	ui_label = "BEZEL IMAGE";
	ui_tooltip = "To add a global bezel-overlay in front when CRT effet is activated";
> = false;

uniform bool USE_OFF_BEZEL <
	ui_label = "OFF BEZEL IMAGE";
	ui_tooltip = "Show an alternate bezel when CRT effect is not activated";
> = true;

uniform float2 arts_aspect_ratio <
	ui_type = "slider";
	ui_min = 0.1f;
	ui_max = 4.0f;
	ui_step = 0.01f;
	ui_label = "Art Images Ratio Adjustement X/Y";
//	ui_category = "Arts Advanced Settings";
//	ui_category_closed = true;
> = float2(1.0, 1.0);

uniform float3 bg_col <
	ui_type = "color";
	ui_label = "Background Color";
	ui_tooltip = "The color the background outside of the display (full screen size)";
//	ui_category = "Arts Advanced Settings";
> = float3(0.0, 0.0, 0.0);

uniform float2 overscan <
	ui_type = "slider";
	ui_min = 0.1f;
	ui_max = 200.0f;
	ui_step = 0.1f;
	ui_label = "Overscan X/Y (%)";
//	ui_category = "Zoom & Crop Advanced Settings";
	ui_spacing = 1;
> = float2(100.0, 100.0);

uniform float2 h_starts <
	ui_type = "drag";
	ui_min = 0.0f;
	ui_max = 100.0f;
	ui_step = 0.05f;
	ui_label = "Horizontal Effect START/END (%)";
	ui_category = "Zoom & Crop Advanced Settings";
	ui_category_closed = true;
> = float2(0.0, 100.0);

uniform float2 v_starts <
	ui_type = "drag";
	ui_min = 0.0f;
	ui_max = 100.0f;
	ui_step = 0.05f;
	ui_label = "Vertical Effect START/END (%)";
	ui_category = "Zoom & Crop Advanced Settings";
> = float2(0.0, 100.0);

uniform float2 src_offsets <
	ui_type = "drag";
	ui_min = -100.0f;
	ui_max = 100.0f;
	ui_step = 0.05f;
	ui_label = "Source Offset X/Y (%)";
	ui_category = "Zoom & Crop Advanced Settings";
> = float2(0.0, 0.0);

uniform bool PASS_THROUGH_BORDERS <
	ui_label = "PASS THROUGH BORDERS";
	ui_tooltip = "To display original graphics outside of the effect area";
	ui_category = "Zoom & Crop Advanced Settings";
> = false;

uniform float2 ext_zoom <
	ui_type = "slider";
	ui_min = 0.1f;
	ui_max = 200.0f;
	ui_step = 0.1f;
	ui_label = "External Zoom X/Y (%)";
	ui_category = "Zoom & Crop Advanced Settings";
> = float2(100.0, 100.0);

uniform float2 ext_offsets <
	ui_type = "drag";
	ui_min = -100.0f;
	ui_max = 100.0f;
	ui_step = 0.05f;
	ui_label = "External Offset X/Y (%)";
	ui_category = "Zoom & Crop Advanced Settings";
> = float2(0.0, 0.0);

uniform bool ACTIVATION_PIXEL_TEST <
	ui_label = "Enable Pixel Test";
	ui_tooltip = "To get the effect only when the 2 pixels tested match their colors (positions should be defined in backbuffer with a resolution of 1920x1080)";
	ui_category = "Pixel Test Advanced Settings";
	ui_category_closed = true;
> = false;

uniform float test_epsilon <
	ui_type = "slider";
	ui_min = 0.0f;
	ui_max = 1.0f;
	ui_step = 0.001f;
	ui_label = "Epsilon (sensitivity)";
	ui_category = "Pixel Test Advanced Settings";
> = 0.01f;

uniform int2 test_pixel <
	ui_type = "input";
	ui_label = "1st Pixel Coordinates X/Y";
	ui_category = "Pixel Test Advanced Settings";
	ui_spacing = 1;
> = int2(0, 0);

uniform float3 test_color <
	ui_type = "color";
	ui_label = "1st Pixel Color (RGB)";
	ui_category = "Pixel Test Advanced Settings";
> = float3(0.0, 0.0, 0.0);

uniform int2 test_pixel2 <
	ui_type = "input";
	ui_label = "2nd Pixel Coordinates X/Y";
	ui_category = "Pixel Test Advanced Settings";
	ui_spacing = 1;
> = int2(0, 0);

uniform float3 test_color2 <
	ui_type = "color";
	ui_label = "2nd Pixel Color (RGB)";
	ui_category = "Pixel Test Advanced Settings";
> = float3(0.0, 0.0, 0.0);


texture background_texture <source="background.png";> { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; };
sampler background_sampler { Texture = background_texture; AddressU = BORDER; AddressV = BORDER; AddressW = BORDER; };

texture bezel_texture <source="bezel.png";> { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; };
sampler bezel_sampler { Texture = bezel_texture; AddressU = BORDER; AddressV = BORDER; AddressW = BORDER; };

texture bezel_off_texture <source="bezel_off.png";> { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; };
sampler bezel_off_sampler { Texture = bezel_off_texture; AddressU = BORDER; AddressV = BORDER; AddressW = BORDER; };

texture frame_texture <source="frame.png";> { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; };
sampler frame_sampler { Texture = frame_texture; AddressU = BORDER; AddressV = BORDER; AddressW = BORDER; };

texture overlay_texture <source="overlay.png";> { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; };
sampler overlay_sampler { Texture = overlay_texture; AddressU = BORDER; AddressV = BORDER; AddressW = BORDER; };

texture mask_texture <source="mask.png";> { Width = BUFFER_WIDTH / 2; Height = BUFFER_WIDTH / 2; Format = RGBA8; };
sampler mask_sampler { Texture = mask_texture; AddressU = WRAP; AddressV = WRAP; AddressW = WRAP;
						MagFilter = LINEAR; MinFilter = LINEAR; MipFilter = LINEAR; MinLOD = 0.0f; };

texture mask2x2_texture <source="mask2x2.png";> { Width = BUFFER_WIDTH / 2; Height = BUFFER_WIDTH / 2; Format = RGBA8; };
sampler mask2x2_sampler { Texture = mask2x2_texture; AddressU = WRAP; AddressV = WRAP; AddressW = WRAP;
						MagFilter = LINEAR; MinFilter = LINEAR; MipFilter = LINEAR; MinLOD = 0.0f; };

texture PixelTestTex { Width = 1; Height = 1; Format = RGBA8; };
sampler PixelTestSampler { Texture = PixelTestTex; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT; };

texture BloomBlurTex { Width = BUFFER_WIDTH / 2; Height = BUFFER_HEIGHT / 2; Format = RGBA8; };
sampler BloomBlurSampler { Texture = BloomBlurTex; };

texture BloomBlurTex2 { Width = BUFFER_WIDTH / 2; Height = BUFFER_HEIGHT / 2; Format = RGBA8; };
sampler BloomBlurSampler2 { Texture = BloomBlurTex2; };


#define FIX(c) max(abs(c), 1e-5);
#define PI 3.141592653589

#define TEX2D(c) pow(tex2D(ReShade::BackBuffer, (c)), float4(CRTgamma, CRTgamma, CRTgamma, CRTgamma))

#define screen_size float2(ReShade::ScreenSize.x, ReShade::ScreenSize.y)

static const float arts_ratio = 16.0f / 9.0f;	// 16:9 art files

float ScreenRatio()
{
	if (inp_screen_ratio == 0.0f)
		return screen_size.x / screen_size.y;
	else
		return inp_screen_ratio;
/*
	switch (inp_screen_ratio)
	{
		case 0:
			return screen_size.x / screen_size.y;
		case 1:
			return 32.0f / 9.0f;
		case 2:
			return 2560.0f / 1080.0f;	// should match most common 21:9 screens...
		case 3:
			return 16.0f / 9.0f;
		case 4:
			return 15.0f / 9.0f;
		case 5:
			return 1.60f;
		case 6:
			return 4.0f / 3.0f;
		case 7:
			return 1.25f;
		case 8:
			return 1.00f;
		case 9:
			return 0.80f;
		case 10:
			return 0.75f;
		case 11:
			return 9.0f / 16.0f;
		default:
			return screen_size.x / screen_size.y;
	}
*/
}


float InGameRatio()
{
	float screen_ratio = ScreenRatio();
	float game_ratio = screen_ratio;
	if (inp_game_ratio != 0.0f)
		game_ratio = inp_game_ratio;
	if (AUTO_ROTATED)
		game_ratio = 1.0f / game_ratio;
	return game_ratio;

/*
	switch (inp_game_ratio)
	{
		case 0:
			return video_size.x / video_size.y;
		case 1:
			return 32.0f / 9.0f;
		case 2:
			return 2560.0f / 1080.0f;	// should match most common 21:9 screens...
		case 3:
			return 16.0f / 9.0f;
		case 4:
			return 15.0f / 9.0f;
		case 5:
			return 1.60f;
		case 6:
			return 4.0f / 3.0f;
		case 7:
			return 1.25f;
		case 8:
			return 1.00f;
		case 9:
			return 0.80f;
		case 10:
			return 0.75f;
		case 11:
			return 9.0f / 16.0f;
		default:
			return video_size.x / video_size.y;
	}
*/
}


float StretchRatio()
{
	float game_ratio = InGameRatio();
	float screen_ratio = ScreenRatio();
	float stretch_ratio = resize_ratio;
/*
	switch (resize_method)
	{
		case 1:
			stretch_ratio = 32.0f / 9.0f;
			break;
		case 2:
			stretch_ratio = 2560.0f / 1080.0f;	// should match most common 21:9 screens...
			break;
		case 3:
			stretch_ratio = 16.0f / 9.0f;
			break;
		case 4:
			stretch_ratio = 15.0f / 9.0f;
			break;
		case 5:
			stretch_ratio = 1.60f;
			break;
		case 6:
			stretch_ratio = 4.0f / 3.0f;
			break;
		case 7:
			stretch_ratio = 1.25f;
			break;
		case 8:
			stretch_ratio = 1.00f;
			break;
		case 9:
			stretch_ratio = 0.80f;
			break;
		case 10:
			stretch_ratio = 0.75f;
			break;
		case 11:
			stretch_ratio = 9.0f / 16.0f;
			break;
	}
*/
	if (AUTO_ROTATED)
		stretch_ratio = 1.0f / resize_ratio;
	if (resize_ratio == 0.0f)
	{
		stretch_ratio = screen_ratio;
	}
	stretch_ratio *= resize_adjust * (screen_size.x / screen_size.y) / screen_ratio;	// Fake resolution fix

	return stretch_ratio;
}


float2 VideoSize()
{
	float stretch_ratio = StretchRatio();
	float screen_ratio = ScreenRatio();

	float2 video_size = screen_size;
	if (screen_ratio < stretch_ratio)
		video_size = float2(screen_size.x, screen_size.x / stretch_ratio);
	else
		video_size = float2(stretch_ratio * screen_size.y, screen_size.y);
/*
	float2 video_size = inp_video_size;

	// 0 can be set when the video and screen sizes are the same.
	if ((inp_video_size.x == 0) && (inp_video_size.y == 0))	// stretched game
	{
		if (screen_size.x / screen_size.y <= stretch_ratio)
			video_size = float2(screen_size.x, screen_size.x / stretch_ratio);
		else
			video_size = float2(stretch_ratio * screen_size.y, screen_size.y);
	}
	else
	{
		if (inp_video_size.x == 0)
			video_size.x = stretch_ratio * video_size.y;
		if (inp_video_size.y == 0)
			video_size.y = video_size.x / stretch_ratio;
	}
*/
	return video_size;
}


float2 ScaleFactor()
{
	float2 video_size = VideoSize();

	return screen_size / video_size;
}


float GameRatio()
{
	float game_ratio = InGameRatio();
	float2 video_size = VideoSize();

	if (inp_game_ratio != 0.0f)
		return game_ratio;
	else
		return video_size.x / video_size.y;
}


float2 TextureDim()
{
	float2 video_size = VideoSize();
	float2 texture_dim = texture_size;
	if (AUTO_ROTATED)
		texture_dim = float2(texture_size.y, texture_size.x);

	// 0 can be set to make the result auto.
	if ((texture_dim.x == 0) && (texture_dim.y == 0))
	{
//		if (resize_method == 0)
//			texture_dim = screen_size / float2(4.0f, 4.0f);	// why not?? :)
//		else
			texture_dim = video_size / float2(4.0f, 4.0f);	// why not?? :)
	}
	else
	{
		if (texture_dim.x == 0)
			texture_dim.x = video_size.x / video_size.y * texture_dim.y;
		if (texture_dim.y == 0)
			texture_dim.y = texture_dim.x * video_size.y / video_size.x;
	}
	return texture_dim;
}


float2 F_Ratio()
{
	float game_ratio = GameRatio();
	float screen_ratio = ScreenRatio();

	if (!ROTATED)
	{
		if (game_ratio <= screen_ratio)
			return float2(screen_ratio / game_ratio, 1.0);
		else
			return float2(1.0, game_ratio / screen_ratio);
	}
	else
		return float2(1.0, screen_ratio * game_ratio);	// No adjustement over vertical axis 
}


float2 AspRatio()
{
	if (!ROTATED)
		return float2(aspect_ratio.x, aspect_ratio.y);
	else
		return float2(aspect_ratio.y, aspect_ratio.x);
}


float2 DisplaySize()
{
	float2 ratio = F_Ratio();

	return screen_size / ratio;
}


float2 HStart()
{
	float2 display_size = DisplaySize();

	return float2(h_starts.x * display_size.x / 100.0f, h_starts.y * display_size.x / 100.0f);
}


float2 VStart()
{
	float2 display_size = DisplaySize();

	return float2(v_starts.x * display_size.y / 100.0f, v_starts.y * display_size.y / 100.0f);
}


bool PIXELTESTS()
{
	float2 video_size = VideoSize();

	float2 offset = float2(0.0, 0.0);
	float2 scale = float2(1.0, 1.0);

//	if ((inp_video_size.x == 0) && (inp_video_size.y == 0))	// stretched game (pixel test positions should be defined in 1920x1080)
//	{
		offset = float2((screen_size.x - video_size.x) / 2.0f, (screen_size.y - video_size.y) / 2.0f);
		scale = float2(video_size.x / 1920.0f, video_size.y / 1080.0f);
//	}

	if (ACTIVATION_PIXEL_TEST)
	{
		float3 delta = tex2D(ReShade::BackBuffer, float2(1.0f * (test_pixel.x * scale.x + offset.x) / screen_size.x, 1.0f * (test_pixel.y * scale.y + offset.y) / screen_size.y)).rgb - test_color;
		float3 delta2 = tex2D(ReShade::BackBuffer, float2(1.0f * (test_pixel2.x * scale.x + offset.x) / screen_size.x, 1.0f * (test_pixel2.y * scale.y + offset.y) / screen_size.y)).rgb - test_color2;
		if (test_epsilon < dot(delta, delta) || test_epsilon < dot(delta2, delta2))
			return false;
	}
	return true;
}


bool PIXELTESTS2()
{
	if (ACTIVATION_PIXEL_TEST)
	{
		if (tex2D(PixelTestSampler, float2(0.5, 0.5)).r < 0.5f)
			return false;
	}
	return true;
}


float2 ExtUV(float2 uv)
{
	float2 video_size = VideoSize();
	float2 display_size = DisplaySize();
	float2 asp_ratio = AspRatio();
	float2 ratio = F_Ratio();

	float2 ext_uv = uv;
	float2 ext_offset = ext_offsets * display_size / (100.0f, 100.0f);

	if (ROTATED)
		ext_uv = float2((1.0f - uv.y), uv.x);
	ext_uv = ((ext_uv - (0.5f, 0.5f)) * screen_size  * asp_ratio / (ext_zoom / (100.0f, 100.0f)) + ext_offset) / screen_size + (0.5f, 0.5f);
//	if (resize_method == 0)
//		ext_uv = ((ext_uv - (0.5f, 0.5f)) * ratio + (0.5f, 0.5f)) * video_size / screen_size;
//	else
		ext_uv = ((ext_uv - (0.5f, 0.5f)) * ratio * video_size / screen_size + (0.5f, 0.5f));
	return ext_uv;
}


float2 ArtsUV(float2 uv)
{
	float screen_ratio = ScreenRatio();
	float game_ratio = GameRatio();

//	return (uv - (0.5f, 0.5f)) * float2(screen_ratio / arts_ratio, 1.0) * arts_aspect_ratio + (0.5f, 0.5f);
	if (game_ratio < screen_ratio || ROTATED)
		return (uv - (0.5f, 0.5f)) * float2(screen_ratio, 1.0f) * arts_aspect_ratio / float2(arts_ratio, 1.0f) + (0.5f, 0.5f);
	else
		return (uv - (0.5f, 0.5f)) * float2(game_ratio, 1.0f / screen_ratio) * arts_aspect_ratio / float2(arts_ratio, 1.0f / game_ratio) + (0.5f, 0.5f);
}


float2 BezelUV(float2 uv)
{
	float screen_ratio = ScreenRatio();
	float2 video_size = VideoSize();
	float game_ratio = GameRatio();
	float2 bezel_uv = ArtsUV(uv) - (0.5f, 0.5f);

/*
	if (resize_method == 0)
	{
		if (game_ratio < screen_ratio || ROTATED)
			return (uv - (0.5f, 0.5f)) * float2(screen_ratio, 1.0f) * arts_aspect_ratio / float2(arts_ratio, 1.0f) + (0.5f, 0.5f);
		else
			return (uv - (0.5f, 0.5f)) * float2(game_ratio, 1.0f / screen_ratio) * arts_aspect_ratio / float2(arts_ratio, 1.0f / game_ratio) + (0.5f, 0.5f);
	}
	if (!ROTATED)
	{
		if ((video_size.x / video_size.y) <= screen_ratio)
		{
			if (game_ratio <= screen_ratio)
				bezel_uv *= float2((video_size.x / video_size.y) / game_ratio, 1.0);
			else
				bezel_uv *= float2((video_size.x / video_size.y) / screen_ratio, game_ratio / screen_ratio );
		}
		else
		{
			if (screen_ratio <= game_ratio)
				bezel_uv *= float2(arts_ratio / screen_ratio, game_ratio / (video_size.x / video_size.y) * arts_ratio / screen_ratio);
			else
				bezel_uv *= float2(arts_ratio / game_ratio, screen_ratio / (video_size.x / video_size.y) * arts_ratio / screen_ratio);
		}
	}
	else
		bezel_uv *= float2(game_ratio / (video_size.x / video_size.y), 1.0);
*/
	return bezel_uv + (0.5f, 0.5f);
}


bool4 OUTS(float2 uv)
{
	float stretch_ratio = StretchRatio();
	float2 h_start = HStart();
	float2 v_start = VStart();
	float2 asp_ratio = AspRatio();
	float2 display_size = DisplaySize();

	float2 offset_ar = (screen_size - display_size / asp_ratio) / (2.0f, 2.0f);
	float2 offset0_ar = offset_ar;
	float2 h_start_ar = h_start / float2(asp_ratio.x, asp_ratio.x);
	float2 v_start_ar = v_start / float2(asp_ratio.y, asp_ratio.y);

	bool OUT_DISPLAY = false;
	bool OUT_STARTS = false;
	bool OUT_DISPLAY_R = false;
	bool OUT_STARTS_R = false;

//	if (resize_ratio != 0.0f)
//	{
		if (stretch_ratio < screen_size.x / screen_size.y)
			offset0_ar = (screen_size - display_size * float2((screen_size.x / screen_size.y) / stretch_ratio, 1.0) / asp_ratio) / (2.0f, 2.0f);
		else
			offset0_ar = (screen_size - display_size * float2(1.0, stretch_ratio / (screen_size.x / screen_size.y)) / asp_ratio) / (2.0f, 2.0f);
//	}
	if (!ROTATED)
	{
		OUT_DISPLAY = true;
		OUT_STARTS = true;
		if ((offset0_ar.y / screen_size.y < uv.y) && (uv.y < (screen_size.y - offset0_ar.y) / screen_size.y))
		{
			if ((offset0_ar.x / screen_size.x < uv.x) && (uv.x < (screen_size.x - offset0_ar.x) / screen_size.x))
			{
				OUT_DISPLAY = false;
				if (((offset_ar.y + v_start_ar.x) / screen_size.y < uv.y) && (uv.y < (offset_ar.y + v_start_ar.y) / screen_size.y))
				{
					if (((offset_ar.x + h_start_ar.x) / screen_size.x < uv.x) && (uv.x < (offset_ar.x + h_start_ar.y) / screen_size.x))
						OUT_STARTS = false;
				}
			}
		}
	}
	else	// Rotated
	{
		OUT_DISPLAY_R = true;
		OUT_STARTS_R = true;
		if ((offset0_ar.x / screen_size.x < (1.0f - uv.y)) && ((1.0f - uv.y) < (screen_size.x - offset0_ar.x) / screen_size.x))
		{
			if ((offset0_ar.y / screen_size.y < uv.x) && (uv.x < (screen_size.y - offset0_ar.y) / screen_size.y))
			{
				OUT_DISPLAY_R = false;
				if (((offset_ar.x + h_start_ar.x) / screen_size.x < (1.0f - uv.y)) && ((1.0f - uv.y) < (offset_ar.x + h_start_ar.y) / screen_size.x))
				{
					if (((offset_ar.y + v_start_ar.x) / screen_size.y < uv.x) && (uv.x < (offset_ar.y + v_start_ar.y) / screen_size.y))
						OUT_STARTS_R = false;
				}
			}
		}
	}
	return bool4(OUT_DISPLAY, OUT_DISPLAY_R, OUT_STARTS, OUT_STARTS_R);
}


float2 DimUV(float2 uv)
{
	float2 h_start = HStart();
	float2 v_start = VStart();
	float2 display_size = DisplaySize();
	float2 asp_ratio = AspRatio();

	float2 offset = (screen_size - display_size) / (2.0f, 2.0f);

	if (ROTATED)
		uv = float2((1.0f - uv.y), uv.x);
	if (ROTATED_180)
		uv = float2((1.0f - uv.x), (1.0f - uv.y));
	uv = (uv - (0.5f, 0.5f)) * asp_ratio + (0.5f, 0.5f);
	uv.x = (uv.x * screen_size.x - h_start.x - offset.x) / (h_start.y - h_start.x);
	uv.y = (uv.y * screen_size.y - v_start.x - offset.y) / (v_start.y - v_start.x);
	return uv;
}


float2 DimXY(float2 xy)
{
	float2 h_start = HStart();
	float2 v_start = VStart();
	float2 display_size = DisplaySize();

	float2 src_offset = src_offsets * display_size / (100.0f, 100.0f);

	xy = (xy - (0.5f, 0.5f)) / (overscan / (100.0f, 100.0f)) + (0.5f, 0.5f);	// Overscan is useful even without curvature;
	xy.x = (xy.x * (h_start.y - h_start.x) + h_start.x + src_offset.x) / display_size.x;
	xy.y = (xy.y * (v_start.y - v_start.x) + v_start.x + src_offset.y) / display_size.y;
	return xy;
}


float2 Asp()
{
	float game_ratio = GameRatio();

	return float2(1.0, 0.75);
}


float fmod(float a, float b)
{
	float c = frac(abs(a / b)) * abs(b);

	return (a < 0) ? -c : c;   /* if ( a < 0 ) c = 0 - c */
}


float intersect(float2 xy, float2 sinangle, float2 cosangle)
{
	float A = dot(xy, xy) + d * d;
	float B = 2.0f * (R * (dot(xy, sinangle) - d * cosangle.x * cosangle.y) - d * d);
	float C = d * d + 2.0f * R * d * cosangle.x * cosangle.y;
	return (-B - sqrt(B * B - 4.0f * A * C)) / (2.0f * A);
}


float2 bkwtrans(float2 xy, float2 sinangle, float2 cosangle)
{
	float c = intersect(xy, sinangle, cosangle);
	float2 pnt = float2(c, c) * xy;
	pnt -= float2(-R, -R) * sinangle;
	pnt /= float2(R, R);
	float2 tang = sinangle / cosangle;
	float2 poc = pnt / cosangle;
	float A = dot(tang, tang) + 1.0f;
	float B = -2.0f * dot(poc, tang);
	float C = dot(poc, poc) - 1.0f;
	float a = (-B + sqrt(B * B - 4.0f * A * C)) / (2.0f * A);
	float2 uv = (pnt - a * sinangle) / cosangle;
	float r = FIX(R * acos(a));
	return uv * r / sin(r / R);
}


float2 fwtrans(float2 uv, float2 sinangle, float2 cosangle)
{
	float r = FIX(sqrt(dot(uv, uv)));
	uv *= sin(r / R) / r;
	float x = 1.0f - cos(r / R);
	float D = d / R + x * cosangle.x * cosangle.y + dot(uv, sinangle);
	return d * (uv * cosangle-x * sinangle) / D;
}


float3 maxscale(float2 sinangle, float2 cosangle)
{
	float2 aspect = Asp();

	float2 c = bkwtrans(-R * sinangle / (1.0 + R / d * cosangle.x * cosangle.y), sinangle, cosangle);
	float2 a = float2(0.5,0.5) * aspect;
	float2 lo = float2(fwtrans(float2(-a.x, c.y), sinangle, cosangle).x,
					   fwtrans(float2(c.x, -a.y), sinangle, cosangle).y) / aspect;
	float2 hi = float2(fwtrans(float2(+a.x, c.y), sinangle, cosangle).x,
					   fwtrans(float2(c.x, +a.y), sinangle, cosangle).y) / aspect;
	return float3((hi + lo) * aspect * 0.5f, max(hi.x - lo.x, hi.y - lo.y));
}


float2 curv(float2 xy)
{
	float2 scale_factor = ScaleFactor();
	float2 aspect = Asp();

	float2 sinangle = sin(float2(tilt.x, tilt.y));
	float2 cosangle = cos(float2(tilt.x, tilt.y));
	float3 stretch = maxscale(sinangle, cosangle);

	xy = (xy - (0.5f, 0.5f)) * aspect * stretch.z + stretch.xy;
	return bkwtrans(xy, sinangle, cosangle) / aspect + (0.5f, 0.5f);
}


float corner(float2 xy)
{
	float2 aspect = Asp();

	xy = min(xy, (1.0f, 1.0f) - xy) * aspect;
	float2 cdist = float2(cornersize, cornersize);
	xy = (cdist - min(xy, cdist));
	float dist = sqrt(dot(xy, xy));
	return clamp((cdist.x - dist) * cornersmooth, 0.0f, 1.0f);
}


float4 scanlineWeights(float distance, float4 color)
{
	// "wid" controls the width of the scanline beam, for each RGB
	// channel The "weights" lines basically specify the formula
	// that gives you the profile of the beam, i.e. the intensity as
	// a function of distance from the vertical center of the
	// scanline. In this case, it is gaussian if width=2, and
	// becomes nongaussian for larger widths. Ideally this should
	// be normalized so that the integral across the beam is
	// independent of its width. That is, for a narrower beam
	// "weights" should have a higher peak at the center of the
	// scanline than for a wider beam.

	float4 wid = 0.3f + 0.1f * pow(color, float4(3.0, 3.0, 3.0, 3.0));
	float4 weights = distance / wid;
	return (lum - 0.3f) * exp(-weights * weights) / wid;
}


float4 PS_CRTGeomMod(float4 vpos : SV_Position, float2 uv : TexCoord) : SV_Target
{
	float2 video_size = VideoSize();
	float2 scale_factor = ScaleFactor();
	float2 texture_dim = TextureDim();
	bool4 OUT_BOOLS = OUTS(uv);
	bool OUT_DISPLAY = OUT_BOOLS.x;
	bool OUT_DISPLAY_R = OUT_BOOLS.y;
	bool OUT_STARTS = OUT_BOOLS.z;
	bool OUT_STARTS_R = OUT_BOOLS.w;
	bool PIXEL_TESTS = PIXELTESTS2();

	float2 arts_uv = ArtsUV(uv);
	float2 ext_uv = ExtUV(uv);

	bool VERTICAL_SCANLINE = VERTICAL_SCANLINES;
	if (AUTO_ROTATED)
		VERTICAL_SCANLINE = !VERTICAL_SCANLINES;

	// Deal with the pixels out of range first
	float4 background = float4(bg_col, 1.0);
	if (USE_BACKGROUND)
	{
		float4 imageBackground = tex2D(background_sampler, arts_uv);
		background.rgb = lerp(background.rgb, imageBackground.rgb, imageBackground.a);
	}

	if (OUT_DISPLAY || OUT_DISPLAY_R)
	{
		return background;
	}
	if (OUT_STARTS || OUT_STARTS_R)
	{
		if (PASS_THROUGH_BORDERS)
		{
			return tex2D(ReShade::BackBuffer, ext_uv);
		}
		else
		{
			return background;
		}
	}

	// Here the pixel are in the affected range
	if (!CRT_EFFECT || !PIXEL_TESTS)	// CRT effect OFF
	{
		return tex2D(ReShade::BackBuffer, ext_uv);
	}
	else	// CRT effect ON
	{
		float2 sc_texture_size = texture_dim * scale_factor;
		if (!VERTICAL_SCANLINE)
			sc_texture_size *= float2(sharper, 1.0);
		else
			sc_texture_size *= float2(1.0, sharper);
		float2 one = float2(1.0, 1.0) / sc_texture_size;

		// Here's a helpful diagram to keep in mind while trying to
		// understand the code:
		//
		//  |      |      |      |      |
		// -------------------------------
		//  |      |      |      |      |
		//  |  01  |  11  |  21  |  31  | <-- current scanline
		//  |      | @    |      |      |
		// -------------------------------
		//  |      |      |      |      |
		//  |  02  |  12  |  22  |  32  | <-- next scanline
		//  |      |      |      |      |
		// -------------------------------
		//  |      |      |      |      |
		//
		// Each character-cell represents a pixel on the output
		// surface, "@" represents the current pixel (always somewhere
		// in the bottom half of the current scan-line, or the top-half
		// of the next scanline). The grid of lines represents the
		// edges of the texels of the underlying texture.

		uv = DimUV(uv);

		// Texture coordinates of the texel containing the active pixel.
		float2 xy = uv;
		if (CURVATURE)
			xy = curv(xy);
		float cval = corner(xy);
		xy = DimXY(xy);

		float2 xy0 = xy;

//		if (resize_method == 0)
//			xy = xy / scale_factor;
//		else
			xy = ((xy - (0.5f, 0.5f)) / scale_factor + (0.5f, 0.5f));

		// Of all the pixels that are mapped onto the texel we are
		// currently rendering, which pixel are we currently rendering?
		float2 ratio_scale = xy * sc_texture_size - (0.5f, 0.5f);
		float2 uv_ratio = frac(ratio_scale);

		// Snap to the center of the underlying texel.
		xy = (floor(ratio_scale) + (0.5f, 0.5f)) / sc_texture_size;
		xy = xy + buffer_offset / video_size;

		// Calculate Lanczos scaling coefficients describing the effect
		// of various neighbour texels in a scanline on the current
		// pixel.
		float4 coeffs = float4(1.0, 1.0, 1.0, 1.0);
		if (!VERTICAL_SCANLINE)
			coeffs = PI * float4(1.0f + uv_ratio.x, uv_ratio.x, 1.0f - uv_ratio.x, 2.0f - uv_ratio.x);
		else
			coeffs = PI * float4(1.0f + uv_ratio.y, uv_ratio.y, 1.0f - uv_ratio.y, 2.0f - uv_ratio.y);

		// Prevent division by zero.
		coeffs = FIX(coeffs);

		// Lanczos2 kernel.
		coeffs = 2.0f * sin(coeffs) * sin(coeffs / 2.0f) / (coeffs * coeffs);

		// Normalize.
		coeffs /= dot(coeffs, float4(1.0, 1.0, 1.0, 1.0));

		// Calculate the effective colour of the current and next
		// scanlines at the horizontal location of the current pixel,
		// using the Lanczos coefficients above.
		float3 mul_res = float3(cval, cval, cval);
		if (!VERTICAL_SCANLINE)
		{
			float4 col  = clamp(mul(coeffs, float4x4(
				TEX2D(xy + float2(-one.x, 0.0)),
				TEX2D(xy),
				TEX2D(xy + float2(one.x, 0.0)),
				TEX2D(xy + float2(2.0f * one.x, 0.0)))),
			0.0f, 1.0f);

			float4 col2 = clamp(mul(coeffs, float4x4(
				TEX2D(xy + float2(-one.x, one.y)),
				TEX2D(xy + float2(0.0, one.y)),
				TEX2D(xy + one),
				TEX2D(xy + float2(2.0f * one.x, one.y)))),
			0.0f, 1.0f);

			// Calculate the influence of the current and next scanlines on
			// the current pixel.
			float4 weights  = scanlineWeights(uv_ratio.y, col);
			float4 weights2 = scanlineWeights(1.0f - uv_ratio.y, col2);

			if (OVERSAMPLE)
			{
				float filter = texture_dim.y / video_size.y;
				uv_ratio.y = uv_ratio.y + ovs_boost * 1.0f / 3.0f * filter;
				weights  = (weights  + scanlineWeights(uv_ratio.y, col)) / 3.0f;
				weights2 = (weights2 + scanlineWeights(abs(1.0f - uv_ratio.y), col2)) / 3.0f;
				uv_ratio.y = uv_ratio.y - ovs_boost * 2.0f / 3.0f * filter;
				weights  = weights  + scanlineWeights(abs(uv_ratio.y), col) / 3.0f;
				weights2 = weights2 + scanlineWeights(abs(1.0f - uv_ratio.y), col2) / 3.0f;
			}
			mul_res *= (col * weights + col2 * weights2).rgb;
		}
		else	// VERTICAL_SCANLINE
		{
			float4 col  = clamp(mul(coeffs, float4x4(
				TEX2D(xy + float2(0.0, -one.y)),
				TEX2D(xy),
				TEX2D(xy + float2(0.0, one.y)),
				TEX2D(xy + float2(0.0, 2.0f * one.y)))),
			0.0f, 1.0f);

			float4 col2 = clamp(mul(coeffs, float4x4(
				TEX2D(xy + float2(one.x, -one.y)),
				TEX2D(xy + float2(one.x, 0.0)),
				TEX2D(xy + one),
				TEX2D(xy + float2(one.x, 2.0f * one.y)))),
			0.0f, 1.0f);

			// Calculate the influence of the current and next scanlines on
			// the current pixel.
			float4 weights  = scanlineWeights(uv_ratio.x, col);
			float4 weights2 = scanlineWeights(1.0f - uv_ratio.x, col2);

			if (OVERSAMPLE)
			{
				float filter = texture_dim.x / video_size.x;
				uv_ratio.x = uv_ratio.x + ovs_boost * 1.0f / 3.0f * filter;
				weights  = (weights  + scanlineWeights(uv_ratio.x, col)) / 3.0f;
				weights2 = (weights2 + scanlineWeights(abs(1.0f - uv_ratio.x), col2)) / 3.0f;
				uv_ratio.x = uv_ratio.x - ovs_boost * 2.0f / 3.0f * filter;
				weights  = weights  + scanlineWeights(abs(uv_ratio.x), col) / 3.0f;
				weights2 = weights2 + scanlineWeights(abs(1.0f - uv_ratio.x), col2) / 3.0f;
			}
			mul_res *= (col * weights + col2 * weights2).rgb;
		}

		// Dot-Mask emulation
		float2 mod_factor = xy0 * texture_dim;
		if (VERTICAL_SCANLINE)
			mod_factor = float2(mod_factor.y, mod_factor.x);
		if (aperture_type == 1 || aperture_type == 2)
		{
			// Mask texture
			float3 mask = float3(1.0, 1.0, 1.0);
			if (aperture_type == 2)
			{
				mod_factor *= float2(0.5, 0.5);
				mask = tex2D(mask2x2_sampler, mod_factor).rgb;
			}
			else
				mask = tex2D(mask_sampler, mod_factor).rgb;
			mul_res *= lerp(float3(1.0, 1.0, 1.0), mask, dotmask * 1.2f);
		}
		else
		{
			// Output pixels are tinted green and delimited magenta.
			float val = 1.0f;
			val = fmod(2.0f * mod_factor.x + 1.0f, 2.0f) - 1.0f;
			val = 2.0f * (abs(val) - 0.5f) + 0.5f;
			mul_res *= lerp(float3(1.0, 1.0f - dotmask, 1.0), float3(1.0f - dotmask, 1.0, 1.0f - dotmask), val);
		}

		// Convert the image gamma for display on our output device.
		mul_res = pow(mul_res, float3(1.0f / monitorgamma, 1.0f / monitorgamma, 1.0f / monitorgamma));

		// Color the texel.
		return float4(mul_res, 1.0);
	}
}


float3 BloomCommon(sampler source, float4 pos, float2 texcoord, float2 dir)
{
	float3 color = tex2D(source, texcoord).rgb;

	float offset[3] = { 0.0, 1.3846153846, 3.2307692308 };
	float weight[3] = { 0.2270270270, 0.3162162162, 0.0702702703 };

	color *= weight[0];

	[loop]
	for(int i = 1; i < 3; ++i)
	{
		color += tex2D(source, texcoord + offset[i] * dir * BloomBlurOffset).rgb * weight[i];
		color += tex2D(source, texcoord - offset[i] * dir * BloomBlurOffset).rgb * weight[i];
	}

	return color;
}

float3 PrepareBlur(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
	float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;
	return pow(color, 1.0 / monitorgamma);
}

float3 BloomBlurHorizontal1(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
	if (!BLOOM)
	{
		discard;
	}
	return BloomCommon(BloomBlurSampler2, pos, texcoord, float2(ReShade::PixelSize.x, 0.0));
}

float3 BloomBlurHorizontal2(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
	if (!BLOOM)
	{
		discard;
	}
	return BloomCommon(BloomBlurSampler, pos, texcoord, 2 * float2(ReShade::PixelSize.x, 0.0));
}

float3 BloomBlurVertical1(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
	if (!BLOOM)
	{
		discard;
	}
	return BloomCommon(BloomBlurSampler2, pos, texcoord, float2(0.0, ReShade::PixelSize.y));
}

float3 BloomBlurVertical2(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
	if (!BLOOM)
	{
		discard;
	}
	return BloomCommon(BloomBlurSampler, pos, texcoord, float2(0.0, ReShade::PixelSize.y));
}


float4 PS_CRTGeomModPixelTest(float4 vpos : SV_Position, float2 uv : TexCoord) : SV_Target
{
	if (PIXELTESTS())
	{
		return float4(1.0, 1.0, 1.0, 1.0);
	}
	else
	{
		return float4(0.0, 0.0, 0.0, 1.0);
	}
}


float4 PS_CRTGeomModFinal(float4 vpos : SV_Position, float2 uv : TexCoord) : SV_Target
{
	bool4 OUT_BOOLS = OUTS(uv);
	bool OUT_DISPLAY = OUT_BOOLS.x;
	bool OUT_DISPLAY_R = OUT_BOOLS.y;
	bool OUT_STARTS = OUT_BOOLS.z;
	bool OUT_STARTS_R = OUT_BOOLS.w;

	bool PIXEL_TESTS = PIXELTESTS2();
	float2 bezel_uv = BezelUV(uv);
	float2 dim_uv = DimUV(uv);

	float4 screen_col = tex2D(ReShade::BackBuffer, uv);
	if (!CRT_EFFECT || !PIXEL_TESTS)	// CRT effect OFF
	{
		if (USE_OFF_BEZEL)
		{
			float4 bezel_off = tex2D(bezel_off_sampler, bezel_uv);
			screen_col.rgb = lerp(screen_col.rgb, bezel_off.rgb, bezel_off.a);
		}
		return screen_col;
	}
	else	// CRT effect ON
	{
		if (OUT_DISPLAY || OUT_DISPLAY_R || OUT_STARTS || OUT_STARTS_R)
		{
			if (USE_BEZEL)
			{
				float4 bezel = tex2D(bezel_sampler, bezel_uv);
				screen_col.rgb = lerp(screen_col.rgb, bezel.rgb, bezel.a);
			}
			return screen_col;
		}

		if (BLOOM)
		{
			float4 bloom = tex2D(BloomBlurSampler2, uv);
			screen_col += pow(bloom * monitorgamma * BloomContrast, BloomContrast) * BloomStrength;
		}

		if (USE_OVERLAY)
		{
			float4 overlay = tex2D(overlay_sampler, dim_uv);
			screen_col.rgb = lerp(screen_col.rgb, overlay.rgb, overlay.a);
		}

		if (USE_FRAME)
		{
			float4 frame = tex2D(frame_sampler, dim_uv);
			screen_col.rgb = lerp(screen_col.rgb, frame.rgb, frame.a);
		}

		if (USE_BEZEL)	// Display also the bezel over the display area
		{
			float4 bezel = tex2D(bezel_sampler, bezel_uv);
			screen_col.rgb = lerp(screen_col.rgb, bezel.rgb, bezel.a);
		}

		// Color the texel.
		return float4(screen_col.rgb, 1.0);
	}
}


technique GeomModCRT
{
	pass PixelTest
	{
		VertexShader = PostProcessVS;
		PixelShader = PS_CRTGeomModPixelTest;
		RenderTarget = PixelTestTex;
	}
	pass CRT_GeomMod
	{
		VertexShader = PostProcessVS;
		PixelShader = PS_CRTGeomMod;
	}
	pass PrepareForBlur
	{
		VertexShader = PostProcessVS;
		PixelShader = PrepareBlur;
		RenderTarget = BloomBlurTex2;
	}
	pass BlurHorizontal1
	{
		VertexShader = PostProcessVS;
		PixelShader = BloomBlurHorizontal1;
		RenderTarget = BloomBlurTex;
	}
	pass BlurHorizontal2
	{
		VertexShader = PostProcessVS;
		PixelShader = BloomBlurHorizontal2;
		RenderTarget = BloomBlurTex2;
	}
	pass BlurVertical1
	{
		VertexShader = PostProcessVS;
		PixelShader = BloomBlurVertical1;
		RenderTarget = BloomBlurTex;
	}
	pass BlurVertical2
	{
		VertexShader = PostProcessVS;
		PixelShader = BloomBlurVertical2;
		RenderTarget = BloomBlurTex2;
	}
	pass Finalize
	{
		VertexShader = PostProcessVS;
		PixelShader = PS_CRTGeomModFinal;
	}
}
