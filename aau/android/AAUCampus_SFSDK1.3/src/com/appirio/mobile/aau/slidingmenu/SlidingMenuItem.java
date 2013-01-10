package com.appirio.mobile.aau.slidingmenu;

public class SlidingMenuItem 
{
	String menuTitle;
	int menuIcon;
	String menuURL;
	String action;

	public String getMenuTitle() 
	{
		return menuTitle;
	}

	public int getMenuIcon() 
	{
		return menuIcon;
	}

	public String getMenuURL() 
	{
		return menuURL;
	}

	public void setMenuTitle(String menuTitle) 
	{
		this.menuTitle = menuTitle;
	}

	public void setMenuIcon(int menuIcon) 
	{
		this.menuIcon = menuIcon;
	}

	public void setMenuURL(String menuURL) 
	{
		this.menuURL = menuURL;
	}

	public void setAction(String action) {
		this.action = action;
	}
	
	public String getAction() {
		return action;
	}

}