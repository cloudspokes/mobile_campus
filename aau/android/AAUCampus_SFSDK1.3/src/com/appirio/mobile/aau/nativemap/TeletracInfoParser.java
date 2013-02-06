package com.appirio.mobile.aau.nativemap;

import java.io.ByteArrayInputStream;
import java.util.ArrayList;
import java.util.List;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Node;

public class TeletracInfoParser {

	DocumentBuilder builder;
	
	public TeletracInfoParser() throws AMException {
		try {
			builder = DocumentBuilderFactory.newInstance().newDocumentBuilder();
		} catch (Exception e) {
			e.printStackTrace();
			
			throw new AMException(e);
		}
	}
	
	public List<Vehicle> parse(String xml) throws AMException {
		try {
			List<Vehicle> result = new ArrayList<Vehicle>();
			
			Document response = builder.parse(new ByteArrayInputStream(xml.getBytes()));
			
			Node root = response.getChildNodes().item(0);
			
			for(int i = 0; i < root.getChildNodes().getLength(); i++) {
				Node vehicleNode = root.getChildNodes().item(i);
				Vehicle vehicle = new Vehicle();
				
				for(int j = 0; j < vehicleNode.getChildNodes().getLength(); j++) {
					Node attr = vehicleNode.getChildNodes().item(j);
					
					if(attr.getNodeName().equals("VehicleName")) {
						vehicle.setVehicleName(attr.getTextContent());
					} else if(attr.getNodeName().equals("Latitude")) {
						vehicle.setLatitude(Double.parseDouble(attr.getTextContent())); 
					} else if(attr.getNodeName().equals("Longitude")) {
						vehicle.setLongitude(Double.parseDouble(attr.getTextContent()));
					}
				}
				
				result.add(vehicle);
			}
			
			return result;
		} catch (Exception e) {
			e.printStackTrace();
			
			throw new AMException(e);
		}
	}
}
