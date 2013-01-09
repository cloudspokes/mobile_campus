package com.appirio.mobile.plugins;

import org.json.JSONArray;

import com.appirio.mobile.AMSalesforceDroidGapActivity;
import com.appirio.mobile.aau.slidingmenu.SlidingMenuLayout;
import com.phonegap.api.Plugin;
import com.phonegap.api.PluginResult;

public class AMMenu extends Plugin {

	@Override
	public PluginResult execute(String action, JSONArray params, String arg2) {
		SlidingMenuLayout rootLayout = ((AMSalesforceDroidGapActivity)this.ctx).rootLayout; 
		
		if (rootLayout.isOpen())
		{
			rootLayout.closeMenu();
		}
		else 
		{
			rootLayout.openMenu();
		}			

		return new PluginResult(PluginResult.Status.NO_RESULT);
	}

}
