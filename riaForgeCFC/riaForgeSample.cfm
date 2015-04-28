<cfset projectName = "">
<cfset conferenceId = "">
<cfset projectUid = "">

<cfset riaForge = createObject("component", "riaForge").init(projectUid)>

<cfdump var="#riaForge.getBlogInfo(projectName)#">
<cfdump var="#riaForge.getProjectInfo()#">
<!--- <cfdump var="#riaForge.getForumInfo(conferenceId)#"> --->