<cfcomponent displayname="RIAForge CFC" hint="I perform various functions to retrieve data for your RIAForge projects">
	
	<cffunction name="init" access="public" output="false" hint="i init the RIAForge CFC" returntype="riaForge">
		<cfargument name="projectUid" required="true" type="numeric" hint="your riaforge uid from your xml feed">
		<cfset instance.projectUid = arguments.projectUid>
		<cfreturn this />
	</cffunction>
	
	<!---
	 Converts an RSS 0.9+ feed into a structure.
	 
	 @param url 	 URL to retrive. (Required)
	 @return Returns a structure. 
	 @author Joe Nicora (joe@seemecreate.com) 
	 @version 1, August 25, 2005 
	--->
	<cffunction name="createRSSQuery">
		/**
		 * Converts an RSS 0.9+ feed into a query.
		 * 
		 * @param url 	 		RSS feed url, must be valid RSS. (Required)
		 * @param feedName 	 	Name to give the feed's information returned as a structure. (Required)
		 * @param colList  List of columns in the query (Required)
		 * @return 				Returns a query. 
		 * @author 				Joe Nicora (joe@seemecreate.com) 
		 * @version 1, 			May 16, 2005 
		 */
		<cfargument name="url" required="Yes" />
		<cfargument name="columnList" required="Yes" />
		
		<cfset var xmlText = "">
		<cfset var start = "">
		<cfset var end = "">
		<cfset var length = "">
		<cfset var xmlDoc = "">
		<cfset var myXMLDoc = "">
		<cfset var feedLen = 0>
		<cfset var result = structNew()>
		<cfset var row = "">
		<cfset var col = "">
			
		<cfset result.feedQuery = queryNew("") />
		
		<cfhttp url="#url#" method="GET" resolveurl="false" /> 

		<cfif isXML(cfhttp.FileContent)>
			<cfscript>
				XMLText = cfhttp.fileContent;
				if (find("<?",XMLText)) {
					start = find("<?",XMLText);
					end = find("?>",XMLText);
					length = end - start;
					XMLText = right(XMLText,len(XMLText)-length);
				}
				XMLDoc = "<root>" & XMLText & "</root>";
				myXMLDoc = XMLParse(XMLDoc,false);
				if(structKeyExists(myXMLDoc.root.rss.channel, "item")){
					feedLen = arrayLen(myXMLDoc.root.rss.channel.item);
					result.title = myXMLDoc.root.rss.channel.title.XMLText;
					result.description = myXMLDoc.root.rss.channel.description.XMLText;
					result.link = myXMLDoc.root.rss.channel.link.XMLText;
				}
				result.feedQuery = queryNew(#columnList#);
				if(feedLen)
				queryAddRow(result.feedQuery,feedLen);
				
				for (row=1; row LTE feedLen; row=row+1) {
					for (col=1; col LTE listLen(columnList); col=col+1) {
						if (NOT col IS 4) 
							querySetCell(result.feedQuery,listGetAt(columnList,col), myXMLDoc.root.rss.channel.item[row][listGetAt(columnList,col)].XMLText,row);
						else
							querySetCell(result.feedQuery,listGetAt(columnList,col),parseDateTime(myXMLDoc.root.rss.channel.item[row][listGetAt(columnList,col)].XMLText),row);
					}	
				}
				
			</cfscript>
		</cfif>
		<cfreturn result />
	</cffunction>
	
	<cffunction name="getBlogInfo" access="remote" output="false" displayname="Gets your latest blog entries for your RIAForge project" returntype="struct" hint="returns a struct containing feed info (latest posts are nested in structure as a query)">
		<cfargument name="projectName" type="string" required="true" hint="the project name (subdomain)">
		<cfset var theURL = "http://" & arguments.projectName & ".riaforge.org/blog/rss.cfm?mode=full">
		<cfreturn createRSSQuery(theURL, 'title,description,link,pubDate,category,guid') />
	</cffunction>
	
	<cffunction name="getProjectInfo" output="true" access="remote" displayname="Get RIAForge Project Info" returntype="query">
		<cfset var RIAForgeURL = "http://www.riaforge.org/index.cfm?event=xml.userprojects&uid=" & instance.projectUid>
		<cfset var returnQ = "">
		<cfset var httpResult = "">
		<cfset var projectXML = "">
		<cfset var i = "">
		<cfset var j = "">
		
		<cfhttp url="#RIAForgeURL#" result="httpResult" timeout="30"/>
		<cfset projectXML = XMLParse(trim(httpResult.fileContent))>
		<cfset returnQ = QueryNew(structKeyList(projectXML.projects.project))>
		<cfset queryAddRow(returnQ, arrayLen(projectXML.projects.project))>
		<cfloop from="1" to="#arrayLen(projectXML.projects.project)#" index="i">
			<cfloop from="1" to="#listLen(returnQ.columnList)#" index="j">
			<cfset querySetCell(returnQ, listGetAt(returnQ.columnList, j), projectXML.projects.project[i][listGetAt(returnQ.columnList, j)].XMLText, i)>
			</cfloop>
		</cfloop>
		<cfreturn returnQ/> 
	</cffunction>
	
<!--- 	 Will add in future
	<cffunction name="getForumInfo" output="false" access="remote" displayname="Get RIAForge Forum Info" returntype="struct">
		<cfargument name="conferenceId" type="uuid" required="true" hint="the forum conferenceid">
		<cfset var theURL = "http://" & instance.projectName & ".riaforge.org/forums/rss.cfm?conferenceid=" & arguments.conferenceId>
	</cffunction> 
--->
</cfcomponent>