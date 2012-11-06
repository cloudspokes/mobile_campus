/*
 * Copyright (c) 2011, salesforce.com, inc.
 * All rights reserved.
 * Redistribution and use of this software in source and binary forms, with or
 * without modification, are permitted provided that the following conditions
 * are met:
 * - Redistributions of source code must retain the above copyright notice, this
 * list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 * - Neither the name of salesforce.com, inc. nor the names of its contributors
 * may be used to endorse or promote products derived from this software without
 * specific prior written permission of salesforce.com, inc.
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */
package com.appirio.mobile.aau;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;

import com.appirio.mobile.AMSalesforceDroidGapActivity;
import com.salesforce.androidsdk.app.ForceApp;
import com.salesforce.androidsdk.ui.LoginActivity;
import com.salesforce.androidsdk.ui.SalesforceDroidGapActivity;
import com.salesforce.androidsdk.ui.SalesforceR;


/**
 * Application class 
 * All Salesforce mobile apps must extend ForceApp. 
 * ForceApp takes care of intializing the network http clients (among other things).x
 */
public class AAUCampusApp extends ForceApp {

	private SalesforceR salesforceR = new SalesforceRImpl();
	
	@Override
	public Class<? extends Activity> getMainActivityClass() {
		return AMSalesforceDroidGapActivity.class;
	}
	
	@Override
	protected String getKey(String name) {
		return null; 
	}

	@Override
	public SalesforceR getSalesforceR() {
		return salesforceR;
	}
	
	@Override
	public void onCreate() {
		super.onCreate();
		
		SharedPreferences settings = getSharedPreferences(
				LoginActivity.SERVER_URL_PREFS_SETTINGS,
				Context.MODE_PRIVATE);
		SharedPreferences.Editor editor = settings.edit();
		editor.putString(LoginActivity.SERVER_URL_CURRENT_SELECTION,
		  getString(R.string.sf_default_url));
		editor.commit();		
	}
}
