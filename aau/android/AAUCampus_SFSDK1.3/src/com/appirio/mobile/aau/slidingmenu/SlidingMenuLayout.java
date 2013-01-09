package com.appirio.mobile.aau.slidingmenu;

import java.util.Timer;
import java.util.TimerTask;

import android.app.Activity;
import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewGroup;

import com.appirio.mobile.aau.R;


public class SlidingMenuLayout extends ViewGroup 
{
    private boolean isMenuOpen = false;
    private int currentPos = 0;
    private int slidedPos = 0;
    private Timer menuAnimTimer;
	
    public SlidingMenuLayout(Context context) 
    {
        super(context);
        init();
    }

    public SlidingMenuLayout(Context context, AttributeSet attrs) 
    {
        super(context, attrs);
        init();
    }

    public SlidingMenuLayout(Context context, AttributeSet attrs, int defStyle) 
    {
        super(context, attrs, defStyle);
        init();
    }

    public boolean isOpen() 
    {
        return isMenuOpen;
    }

    public void openMenu() 
    {
        if (isMenuOpen) 
        {
            return;
        }
        currentPos = 0;
        menuAnimTimer = new Timer();
        menuAnimTimer.schedule(new TimerTask() 
        {
            @Override
            public void run() 
            {
                currentPos += slidedPos / 10;
				if (currentPos >= slidedPos)
                {
                    currentPos = slidedPos;
                    menuAnimTimer.cancel();
                }
                ((Activity) getContext()).runOnUiThread(new Runnable() 
                {
                    public void run() 
                    {
                        requestLayout();
                    }
                });
            }
        }, 16, 16);
        isMenuOpen = true;
    }

    public void closeMenu() 
    {
        if (!isMenuOpen) 
        {
            return;
        }
        menuAnimTimer = new Timer();
        menuAnimTimer.schedule(new TimerTask() 
        {
            @Override
            public void run()
            {
                currentPos -= slidedPos / 10;
                if (currentPos <= 0) 
                {
                    currentPos = 0;
                    menuAnimTimer.cancel();
                }
                ((Activity) getContext()).runOnUiThread(new Runnable() 
                {
                    public void run() 
                    {
                        requestLayout();
                    }
                });
            }
        }, 16, 16);
        isMenuOpen = false;
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) 
    {
        int width = MeasureSpec.getSize(widthMeasureSpec);
        int height = MeasureSpec.getSize(heightMeasureSpec);        
        Boolean useFixedWidth = getResources().getBoolean(R.bool.use_fixed_width);
        if (useFixedWidth)
        {
        	int slidingPosition = (int) getResources().getDimension(R.dimen.slider_width_value);
        	slidedPos = slidingPosition;
        }
        else
        {
        	slidedPos = width * 2 / 3;
        }        
        super.setMeasuredDimension(width, height);
        final int count = getChildCount();
        for (int i = 0; i < count; i++) 
        {
            View view = getChildAt(i);
            if (i == count - 1) 
            {
                measureChild(view, MeasureSpec.makeMeasureSpec(width, MeasureSpec.EXACTLY), heightMeasureSpec);
            } 
            else 
            {
                measureChild(view, MeasureSpec.makeMeasureSpec(slidedPos, MeasureSpec.EXACTLY), heightMeasureSpec);
            }
        }
    }

    @Override
    protected void onLayout(boolean changed, int left, int top, int right, int bottom) 
    {
        int width = right - left;
        int height = bottom - top;
        final int count = getChildCount();
        for (int i = 0; i < count; i++) 
        {
            View view = getChildAt(i);
            if (i == count - 1) 
            {
                view.layout(currentPos, 0, width + currentPos, height);
            } 
            else 
            {
                view.layout(0, 0, slidedPos, height);
            }
        }
    }

    private void init() 
    {
        setChildrenDrawingOrderEnabled(true);
    }
}