/*Copyright (c) 2018, Daniel Appleman

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, 
this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, 
this list of conditions and the following disclaimer in the documentation 
and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors 
may be used to endorse or promote products derived from this software without 
specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES 
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND 
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF 
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
public with sharing class PersonAccountSupport {

	@TestVisible public static Boolean fakePersonAccountDuringTest = false;

	private static Set<string> accountFields = null;

    public static Boolean isPersonAccountOrg()
    {
    	if(accountFields==null) accountFields = 
    		Schema.Sobjecttype.Account.fields.getMap().keyset();
    	return AccountFields.contains('personcontactid');
    }
    
    // Map from contact field to account field
    public static String getPersonAccountAlias(String fieldName)
	{
		fieldName = fieldname.toLowerCase();	// Case insensitive
		
		// Unchanged - FirstName, LastName, etc.
		if(accountFields.contains(fieldName)) return fieldName;

		// Replace aliased __c with __pc
		fieldName = fieldName.replace('__c', '__pc');
		if(accountFields.contains(fieldName)) return fieldname;

		if(accountFields.contains('person' + fieldName)) 
			return ('person' + fieldName);

		return null;
	}
	
	public static void processContactTrigger(
		Boolean isBefore, List<Contact> newList, Map<ID, Contact> oldMap)
	{
		for(Contact ct: newList)
		{
			if(ct.LeadSource=='Web' || ct.LeadSource=='Phone Inquiry') 
				ct.Level2__c = 'Primary'; 
				else ct.Level2__c = 'Secondary';
		}
	}
	

	public static void processAccountTrigger(
		Boolean isBefore, List<Account> newList, Map<ID, Account> oldMap)
	{
		if(!isPersonAccountOrg()) return;

		if(isBefore)
		{
			// Using before approach
			String leadSourceAlias = getPersonAccountAlias('LeadSource');
			String levelAlias = getPersonAccountAlias('Level2__c');
			for(Account act: newList)
			{
				if(leadSourceAlias!=null && levelAlias!=null && 
					(Boolean)act.get('IsPersonAccount'))
				{	// Will only be valid on person accounts
					if(act.get(leadSourceAlias)=='Web' || 
						act.get(leadSourceAlias)=='Phone Inquiry')
						act.put(levelAlias,'Primary'); 
						else act.put(levelAlias,'Secondary');
				}
			}
		}
		
	}

}