package com.appirio.mobile.aau.slidingmenu;

import java.util.ArrayList;

import org.xmlpull.v1.XmlPullParser;

import android.content.Context;
import android.content.res.XmlResourceParser;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.ListAdapter;
import android.widget.TextView;

import com.appirio.mobile.aau.R;

public class SlidingMenuAdapter extends BaseAdapter implements ListAdapter 
{
	LayoutInflater inflater;
	ArrayList<SlidingMenuItem> slidingMenuItems = new ArrayList<SlidingMenuItem>();
	
	public SlidingMenuAdapter(LayoutInflater inflater, Context context) 
	{
		this.inflater = inflater;
		parseXmlForMenuItems(context);
	}

	@Override
	public int getCount() 
	{
		return slidingMenuItems.size();
	}

	@Override
	public Object getItem(int position) 
	{
		return slidingMenuItems.get(position).getMenuURL();
	}

	@Override
	public long getItemId(int position) 
	{
		return 0;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent)
	{
		View view = inflater.inflate(R.layout.menu_item_layout, null);
		TextView menuTitle = (TextView) view.findViewById(R.id.menu_item_title);
		menuTitle.setText(slidingMenuItems.get(position).getMenuTitle());
		ImageView menuIcon = (ImageView) view.findViewById(R.id.menu_item_icon);
		menuIcon.setImageResource(slidingMenuItems.get(position).getMenuIcon());
		return view;
	}
	
	public void parseXmlForMenuItems(Context context) 
	{
		SlidingMenuItem menuItem = null;
		Boolean itemStarted = false;
		ArrayList<String> previousTags = new ArrayList<String>();
		try 
		{
			XmlResourceParser menuData = context.getResources().getXml(R.xml.sliding_menu_items);
			menuData.next();
			int eventType = menuData.getEventType();
			while (eventType != XmlPullParser.END_DOCUMENT) 
			{				
				if (eventType == XmlPullParser.START_TAG) 
				{
					previousTags.add(menuData.getName());
					if (menuData.getName().equalsIgnoreCase("item") && !itemStarted)
					{
						itemStarted = true;
						menuItem = new SlidingMenuItem();
					}
				} 
				else if (eventType == XmlPullParser.END_TAG)
				{
					previousTags.remove(previousTags.size() - 1);
					if (menuData.getName().equalsIgnoreCase("item") && itemStarted)
					{
						itemStarted = false;
						slidingMenuItems.add(menuItem);
					}
				} 
				else if (eventType == XmlPullParser.TEXT) 
				{
					String temp = previousTags.get(previousTags.size() - 1);
					if (temp.equalsIgnoreCase("title"))
					{
						menuItem.setMenuTitle(menuData.getText());
					}
					else if (temp.equalsIgnoreCase("icon"))
					{
						menuItem.setMenuIcon(context.getResources().getIdentifier(menuData.getText(), "drawable", context.getPackageName()));
					}
					else if (temp.equalsIgnoreCase("url"))
					{
						menuItem.setMenuURL(menuData.getText());
					}
				}
				eventType = menuData.next();
			}
		} 
		catch (Exception ex) 
		{
			Log.d("SlidingMenuAdapter", "Exception Occured while parsing xml menu : - " + ex.toString());
			ex.printStackTrace();
		}
	}
}