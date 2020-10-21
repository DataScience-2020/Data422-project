package com.bericotech.clavin;

import java.io.File;
import java.io.*;
import java.util.List;
import java.util.HashMap;
import java.util.*;

import com.bericotech.clavin.resolver.ResolvedLocation;
import com.bericotech.clavin.util.TextUtils;

/*#####################################################################
 * 
 * CLAVIN (Cartographic Location And Vicinity INdexer)
 * ---------------------------------------------------
 * 
 * Copyright (C) 2012-2013 Berico Technologies
 * http://clavin.bericotechnologies.com
 * 
 * ====================================================================
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * permissions and limitations under the License.
 * 
 * ====================================================================
 * 
 * WorkflowDemo.java
 * 
 *###################################################################*/

/**
 * This code is modified from the example showing how to use CLAVIN's capabilities.
 * by Jian ZHOU
 * Jian ZHOU 51404140 jzh210@uclive.ac.nz
 */
public class WorkflowDemo {

    /**
     * Run this after installing & configuring CLAVIN to get a sense of
     * how to use it.
     * 
     * @param args              not used
     * @throws Exception
     */
    public static void main(String[] args) throws Exception {
        
        // Instantiate the CLAVIN GeoParser
        GeoParser parser = GeoParserFactory.getDefault("./IndexDirectory");
        
        // Unstructured text file about Somalia to be geoparsed
        File inputFile = new File("/Users/azurewood/UC/DATA422Wrangling/project/code/data/descr_2010.txt");
        
        // Grab the contents of the text file as a String
        String inputString = TextUtils.fileToString(inputFile);
        
        // Parse location names in the text into geographic entities
        List<ResolvedLocation> resolvedLocations = parser.parse(inputString);
		
		// Create a HashMap object called story_places
		HashMap<String, Integer> story_places = new HashMap<String, Integer>();
        
        // Display the ResolvedLocations found for the location names
        for (ResolvedLocation resolvedLocation : resolvedLocations)
		{
			if(resolvedLocation.getConfidence() == 1)
			{
				String place = resolvedLocation.getMatchedName();
				if(story_places.containsKey(place))
				{
					Integer value = story_places.get(place);
					story_places.put(place, 1 + value);
				}
				else
				{
					story_places.put(place, 1);     //now contains "key" entry
				}
			}
		}
		try
		{
			FileWriter fw = new FileWriter("story_place_2010.csv");
			fw.write("Place,Occur\n");
	        //System.out.println(resolvedLocation);
			for(Map.Entry m : story_places.entrySet())
			{    
				System.out.println(m.getKey()+", "+m.getValue());
				fw.write(m.getKey()+","+m.getValue()+"\n");    
			}
			fw.close();
		}
		catch(IOException e)
		{
		}
		
        // And we're done...
        System.out.println("\n\"That's all folks!\"");
    }
}
