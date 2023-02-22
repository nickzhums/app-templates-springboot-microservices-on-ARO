/*
 * Copyright 2002-2013 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.springframework.samples.petclinic.owner;

import java.util.Collection;
import java.util.Map;
import java.net.HttpURLConnection;
import java.net.URL;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.InitBinder;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.transaction.annotation.Transactional;

/**
 * @author Juergen Hoeller
 * @author Ken Krebs
 * @author Arjen Poutsma
 * @author Michael Isvy
 */
@RestController
class OwnerController {		
	
	@Autowired
    private OwnerRepository owners;

    @InitBinder
    public void setAllowedFields(WebDataBinder dataBinder) {
        dataBinder.setDisallowedFields("id");
    }

    @RequestMapping(method = RequestMethod.GET, value = "/owners/new", produces = {"application/json"})
    public Owner initCreationForm() {
    	System.out.println("SERVICE owner-controller.... METHOD GET on new owner....");
        Owner owner = new Owner();
        return owner;        
    }
    
    @RequestMapping(method = RequestMethod.POST, value = "/owners/new")  
    @Transactional
    public Owner processCreationForm(@RequestBody Owner owner) {
    	System.out.println("SERVICE owner-controller.... METHOD POST on new owner....");    
    	System.out.println(owner.toString());
    	owner = owners.save(owner);
    	System.out.println("Saving owner passed");
    	System.out.println(owner.toString());
    	return owner;
    }

    @RequestMapping(method = RequestMethod.GET, value = "/owners/find", produces = {"application/json"})
    public Owner initFindForm(Map<String, Object> model) {
    	System.out.println("SERVICE owner-controller.... METHOD GET on find owner....");
    	Owner owner = new Owner();
		getMedicines();
        return owner;
    }

    @RequestMapping(method = RequestMethod.POST, value = "/owners")
    @Transactional
    public Owner[] processFindForm(@RequestBody Owner owner) {
    	System.out.println("SERVICE owner-controller.... METHOD POST on find all owners....");
        // allow parameterless Post request for /owners to return all records
        if (owner.getLastName() == null) {
            owner.setLastName(""); // empty string signifies broadest possible search
        }

        // find owners by last name        
        Collection<Owner> results = this.owners.findByLastName(owner.getLastName());
        Owner[] response = results.toArray(new Owner[results.size()]);
        getOwnerDetails();
        return response;
    }
		
	
	public void getMedicines() {
		if (isDemo()) {
			try {
				String medicineUrl = getExternalUrl("http://petclinic-medicines/");
				URL url = new URL(medicineUrl);
				HttpURLConnection con = (HttpURLConnection) url.openConnection();
				con.setConnectTimeout(3000); // set timeout to 5 seconds
				if (con.getResponseCode() == 200) {
					System.out.println(medicineUrl + " Third party call successfully made, response code : " + con
							.getResponseCode());
				} else {
					System.out.println(medicineUrl + " Third party call attempted response code : " + con
							.getResponseCode());
				}
			}
			catch (Exception e) {
				System.out.println("exception encountered while making HTTP Call");
				e.printStackTrace();
			}
		}
	}
	
	private void getOwnerDetails() {
		if(isDemo()){
			boolean keepLooping = true;
			long timeStart = System.currentTimeMillis();
			getOwnerAdressDetails(keepLooping,timeStart);		
		}
	}
	
	private void getOwnerAdressDetails(boolean keepLooping, long timeStart){
		
		long thresh = getCpuMillis();
		while(keepLooping){
			long timeNow = System.currentTimeMillis();			
			if((timeNow - timeStart) >=  thresh || (timeNow - timeStart) >= (300 * 1000)){
				keepLooping = false;
			}
		}
	}

	private boolean isDemo() {
		boolean demo = false;
		try {
			demo = Boolean.parseBoolean(System.getenv("DEMO"));
			System.out.println("DEMO: "+demo);
		}
		catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return demo;
	}
	
	private String getExternalUrl(String defaultUrl) {
		String demoUrl = defaultUrl;
		try {
			demoUrl = System.getenv("DEMO_EXTERNAL_URL");
			System.out.println("DEMO_EXTERNAL_URL: "+demoUrl);
			if(demoUrl == null || demoUrl.length() == 0) {
				demoUrl = defaultUrl;
			}
		}
		catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return demoUrl;
	}
	
	private Long getCpuMillis() {
		Long demoCpu = 5000L;
		demoCpu = Long.parseLong(System.getenv("DEMO_CPU_MILLIS"));
		System.out.println("DEMO_CPU_MILLIS: "+demoCpu);
		try {
			if(demoCpu == null || demoCpu <= 0) {
				demoCpu = 5000L;
			}
		}
		catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return demoCpu;
	}
	
	
	
    @RequestMapping(method = RequestMethod.GET, value = "/owners/{ownerId}/edit")
    @Transactional
    public Owner initUpdateOwnerForm(@PathVariable("ownerId") int ownerId) {
    	System.out.println("SERVICE owner-controller.... METHOD GET on edit owner....");
        Owner owner = this.owners.findById(ownerId);
        return owner;        
    }

    @RequestMapping(method = RequestMethod.POST, value = "/owners/{ownerId}/edit")
    @Transactional
    public Owner processUpdateOwnerForm(@RequestBody Owner owner) {        
    	System.out.println("SERVICE owner-controller.... METHOD POST on edit owner....");
        owner = owners.save(owner);
        return owner;        
    }

    @RequestMapping(method = RequestMethod.GET, value="/owners/{ownerId}")
    @Transactional
    public Owner showOwner(@PathVariable("ownerId") int ownerId) {
    	System.out.println("SERVICE owner-controller.... METHOD GET on show owner by id....");    	
    	Owner owner = this.owners.findById(ownerId);
    	System.out.println("PET COUNT : " + owner.getPets().size() + " for owner id : " + ownerId);
    	return owner;
    }
    
    /*@RequestMapping(method = RequestMethod.POST, value = "/owners/{ownerId}/pets/new")
    public PetClinicRequestBody getPet(@RequestBody PetClinicRequestBody request, @PathVariable("ownerId") int ownerId) {
    	System.out.println("SERVICE owner-controller.... METHOD POST on get Pet....");   
    	Owner owner = this.owners.findById(ownerId);
    	Pet pet = request.getPet();
    	System.out.println("Pet Details for add : " + pet.getName() + "  " + pet.getBirthDate() + "  " + pet.getType());        
    	owner.addPet(pet);    	
        System.out.println("PET COUNT : " + owner.getPets().size() + " for owner id : " + pet.getOwner().getId());
        request.setOwner(owner);
        request.setPet(pet);    
        System.out.println(pet.getOwner().toString());
        System.out.println("End of get Pet method....");
        return request;        
    }*/
    
    /*@RequestMapping(method = RequestMethod.POST, value = "/owners/{ownerId}/pets/add")
    @Transactional
    public PetClinicRequestBody addNewPet(@RequestBody PetClinicRequestBody request, @PathVariable("ownerId") int ownerId) {
    	System.out.println("SERVICE owner-controller.... METHOD POST on add New Pet....");   
    	Owner owner = this.owners.findById(ownerId);
    	Pet pet = request.getPet();
    	System.out.println("Pet Details for add : " + pet.getName() + "  " + pet.getBirthDate() + "  " + pet.getType());        
    	owner.addPet(pet);
    	owner = owners.save(owner);
        System.out.println("Owner saved back for pet type..");        
        System.out.println("PET COUNT : " + owner.getPets().size() + " for owner id : " + ownerId);
        request.setOwner(owner);
        request.setPet(pet);        
        System.out.println("End of Add New Pet method....");
        return request;        
    }*/
}
