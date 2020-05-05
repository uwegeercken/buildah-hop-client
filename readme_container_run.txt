
<h2>Image for running the project-hop command line client</h2>
<p>Run a hop workflow or pipeline using the Hop command line client. <a href="http://www.project-hop.org/">Read more on Hop</a>.</p>
<p>On start of the container the environment variables will be processed and the run configuration will be created using either the defaults or the variables specified. The hop file from the volume mount is then run using the hop-run.sh command line script. Once the Hop workflow or pipeline finishes, the container exits.</p>
<h3>Folders and files</h3>
<h4>Folders</h4>
<table width="100%">
	<tr>
		<td width="30%"><b>Folder</b></td><td width="70%"><b>Description</b></td>
	<tr>
	<tr>
		<td width="30%">/opt/hop</td><td width="70%">location of the hop package</td>
	<tr>
</table>
<h4>Files</h4>
<table width="100%">
	<tr>
		<td width="30%"><b>File</b></td><td width="70%"><b>Description</b></td>
	<tr>
	<tr>
		<td width="30%">/entrypoint.sh</td><td width="70%">entrypoint for the container to process variables and run the hop-run.sh script</td>
	</tr>
	<tr>
		<td width="30%">/generate_runconfig.sh</td><td width="70%">called by entrypoint script. script to process runconfig variables and merge them with a template to create a runconfig file</td>
	<tr>
</table>

<h3>Environment variables</h3>
<p>Set the environment variables as appropriate. You are required to specify the variable that are listed as &quot;Mandatory&quot;</p>
<table width="100%">
	<tr>
		<td width="10%"><b>Variable</b></td><td width="40%"><b>Description</b></td><td width="25%"><b>Default</b></td><td width="25%"><b>Example</b></td>
	<tr>
		<td width="10%">HOP_LEVEL</td><td width="40%">Optional. Log level. Possible values: Nothing, Error, Minimal, Basic, Detailed, Debug, RowLevel</td><td width="25%">Basic</td><td width="25%">HOP_LEVEL=Basic</td>
	</tr>
	<tr>
		<td width="10%">HOP_FILE</td><td width="40%">Mandatory. The hop file to run</td><td width="25%">None</td><td width="25%">HOP_FILE=/files/test1.hpl</td>
	</tr>
	<tr>
		<td width="10%">HOP_PARAMETERS</td><td width="40%">Optional. Parameters. Key/value pairs for the hop process. Separate multiple parameters with a comma.</td><td width="25%">None</td><td width="25%">HOP_PARAMETERS=myparam=test</td>
	</tr>
	<tr>
		<td width="10%">HOP_SYSTEM_PROPERTIES</td><td width="40%">Optional. System properties. Key/value pairs for the hop process. Separate multiple properties with a comma.</td><td width="25%">None</td><td width="25%">HOP_SYSTEM_PROPERTIES=myprop=123,yourprop=ABC</td>
	</tr>
	<tr>
		<td width="10%">HOP_RUNCONFIG</td><td width="40%">Optional. Name of the run configuration. Currently there is only one configuration (named &quot;default&quot;). Adjust the details for this configuration using the HOP_RUNCONFIG_* variables</td><td width="25%">None</td><td width="25%">HOP_RUNCONFIG=default</td>
	</tr>
	<tr>
		<td width="10%">HOP_RUNCONFIG_FEEDBACK_SIZE</td><td width="40%">Optional. Feedback size.</td><td width="25%">50000</td><td width="25%">HOP_RUNCONFIG_FEEDBACK_SIZE=10000</td>
	</tr>
	<tr>
		<td width="10%">HOP_RUNCONFIG_ROWSET_SIZE</td><td width="40%">Optional. Rowset size.</td><td width="25%">10000</td><td width="25%">HOP_RUNCONFIG_ROWSET_SIZE=4000</td>
	</tr>
	<tr>
		<td width="10%">HOP_RUNCONFIG_SAFE_MODE</td><td width="40%">Optional. Safe mode.</td><td width="25%">N</td><td width="25%">HOP_RUNCONFIG_SAFE_MODE=Y</td>
	</tr>
	<tr>
		<td width="10%">HOP_RUNCONFIG_SHOW FEEDBACK</td><td width="40%">Optional. Show feedback.</td><td width="25%">N</td><td width="25%">HOP_RUNCONFIG_SHOW_FEEDBACK=N</td>
	</tr>
	<tr>
		<td width="10%">HOP_RUNCONFIG_GATHER_METRICS</td><td width="40%">Optional. Gather metrics.</td><td width="25%">N</td><td width="25%">HOP_RUNCONFIG_GATHER_METRICS=N</td>
	</tr>
	<tr>
		<td width="10%">HOP_RUNCONFIG_TOPO_SORT</td><td width="40%">Optional. Topo sort.</td><td width="25%">N</td><td width="25%">HOP_RUNCONFIG_TOPO_SORT=N</td>
	</tr>
	<tr>
		<td width="10%">HOP_ENVIRONMENT</td><td width="40%">Optional. Environment to use.</td><td width="25%">None</td><td width="25%"></td>
	</tr>
	<tr>
		<td width="10%">HOP_PIPELINE</td><td width="40%">Optional. Force execution of a Hop pipeline (if it cannot be determined by the filename).</td><td width="25%">None</td><td width="25%">HOP_PIPELINE=1</td>
	</tr>
	<tr>
		<td width="10%">HOP_WORKFLOW</td><td width="40%">Optional. Force execution of a Hop workflow (if it cannot be determined by the filename).</td><td width="25%">None</td><td width="25%">HOP_WORKFLOW=1</td>
	</tr>
	<tr>
		<td width="10%">HOP_OPTIONS</td><td width="40%">Optional. HOP additional Java options.</td><td width="25%">-Xmx2048m</td><td width="25%">HOP_OPTIONS=-Xmx1024m</td>
	</tr>

</table>

<h3>Run a Container</h3>
<p>You can set the environment variables on the command line. like e.g. --env HOP_FILE=/files/test1.hpl. But it is easier to put them in a single file containing all variables (here: hop.env) and reference the file when running the container.</p>
<p>Note: You must specify the variable: HOP_FILE. The file needs to point to a hop file in the volume mount that is defined with the -v flag.</p>
<h4>Examples:</h4>
<p><code>docker run -v ./files:/files:Z --env HOP_FILE=/files/test1.hpl --env HOP_RUNCONFIG=default uwegeercken/hop:latest</code></p>
<p><code>docker run -v ./files:/somefolder:Z --env HOP_FILE=/somefolder/test1.hpl --env HOP_RUNCONFIG=default --env HOP_PARAMETERS=myparam=123,myparam2=Abc uwegeercken/hop:latest</code></p>
<p><code>docker run -v ./files:/files:Z --env-file hop.env uwegeercken/hop:latest</code></p>