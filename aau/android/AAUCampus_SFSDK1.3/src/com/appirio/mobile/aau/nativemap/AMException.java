package com.appirio.mobile.aau.nativemap;

public class AMException extends Exception {

	public AMException() {
	}

	public AMException(String detailMessage) {
		super(detailMessage);
	}

	public AMException(Throwable throwable) {
		super(throwable);
	}

	public AMException(String detailMessage, Throwable throwable) {
		super(detailMessage, throwable);
	}

}
