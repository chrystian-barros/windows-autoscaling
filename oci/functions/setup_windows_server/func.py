import io
import oci
import json
import os
import base64
import winrm
from fdk import response
from modules.get_jenkins_crumb import *
from modules.create_node import *
from modules.get_node_secret import *

def initialize_function(ctx, data: io.BytesIO = None):
    body = json.loads(data.getvalue())

    # Retrieve Windows instance name from event body
    instance_name = body.get('data', {}).get('resourceName')

    # Retrieve Windows instance password content for OCI authentication
    signer = oci.auth.signers.get_resource_principals_signer()
    secret_client = oci.secrets.SecretsClient(config={}, signer=signer)
    secret_content = secret_client.get_secret_bundle(secret_id=f"{os.getenv('SECRET_OCID')}")
    secret_bundle = secret_content.data.secret_bundle_content.content
    keybase64bytes = secret_bundle.encode("ascii")
    keybytes = base64.b64decode(keybase64bytes)
    instance_password = keybytes.decode("ascii")

    # Retrieve Datadog API Key to install and synchronize agent
    datadog_secret_content = secret_client.get_secret_bundle(secret_id=f"{os.getenv('DATADOG_API_KEY')}")
    datadog_secret_bundle = datadog_secret_content.data.secret_bundle_content.content
    dg_keybase64bytes = datadog_secret_bundle.encode("ascii")
    dg_keybytes = base64.b64decode(dg_keybase64bytes)
    datadog_api_key = dg_keybytes.decode("ascii")

    # Retrieve Jenkins service account API key
    jenkins_secret_content = secret_client.get_secret_bundle(secret_id=f"{os.getenv('JENKINS_API_KEY')}")
    jenkins_secret_bundle = jenkins_secret_content.data.secret_bundle_content.content
    jk_keybase64bytes = jenkins_secret_bundle.encode("ascii")
    jk_keybytes = base64.b64decode(jk_keybase64bytes)
    jenkins_api_key = jk_keybytes.decode("ascii")

    # Retrieve Jenkins Crumb
    jenkins_crumb = get_jenkins_crumb(
        f"{os.getenv('JENKINS_URL')}",
        f"{os.getenv('JENKINS_USERNAME')}",
        f"{jenkins_api_key}"
    )
    jenkins_crumb_response = json.loads(jenkins_crumb)

    # Create Jenkins Node
    jenkins_node = create_node(
        f"{os.getenv('JENKINS_URL')}",
        f"{jenkins_crumb_response.get('crumb')}", 
        f"{instance_name}", 
        f"Puerto Rico Infrastructure - {instance_name}", 
        "2", 
        "/var/jenkins",
        "dev-puertorico_infrastructure",
        f"{os.getenv('JENKINS_USERNAME')}",
        f"{jenkins_api_key}"
    )
    jenkins_node_response = json.loads(jenkins_node)

    # Retrieve Jenkins Node Secret
    jenkins_node_secret = get_node_secret(
        f"{os.getenv('JENKINS_URL')}", 
        f"{instance_name}", 
        f"{os.getenv('JENKINS_USERNAME')}", 
        f"{jenkins_api_key}"
    )
    jenkins_node_secret_response = json.loads(jenkins_node_secret)

    # Retrieve the list of private IP addresses of the instances from the event body
    core_client = oci.core.ComputeClient(config={}, signer=signer)
    list_vnic_attachments_response = core_client.list_vnic_attachments(
        compartment_id = body.get('data', {}).get('compartmentId'),
        instance_id = body.get('data', {}).get('resourceId')
    )

    # Initialize service client with default config file
    core_client = oci.core.VirtualNetworkClient(config={}, signer=signer)
    get_vnic_response = core_client.get_vnic(
        vnic_id = list_vnic_attachments_response.data[0].vnic_id
    )

    # Create a session
    session = winrm.Session(
        f"http://{get_vnic_response.data.private_ip}:5985/wsman", 
        auth=(
            'opc', 
            f"{instance_password}"
        ), 
        transport='ntlm',
        operation_timeout_sec=180,
        read_timeout_sec=190
    )

    script = rf"""
Start-Transcript -Path "$env:USERPROFILE\Documents\debug.txt";
$scriptContent = @'

# Import root module
Import-Module -Name "\\{os.getenv('MOUNT_TARGET_IP')}\{(os.getenv('EXPORT_PATH')).replace('/','')}\PuertoRicoInfrastructure\PuertoRicoInfrastructure.psm1";

# Set required environment variables
Set-PREnvironmentVariables -MountTargetIP "{os.getenv('MOUNT_TARGET_IP')}" `
 -ExportPath "{os.getenv('EXPORT_PATH')}";
New-PSDrive -Name "P" -PSProvider FileSystem -Root "\\{os.getenv('MOUNT_TARGET_IP')}\{(os.getenv('EXPORT_PATH')).replace('/','')}" -Persist -Scope Global;

# Install and configure Jenkins agent
Install-JenkinsAgent -JenkinsURL "https://{os.getenv('JENKINS_URL')}" `
 -NodeName "{instance_name}" `
 -NodeSecret "{jenkins_node_secret_response.get('secret')}" `
 -ServiceName "JenkinsAgent" `
 -ServiceDescription "{os.getenv('JENKINS_URL')} - Jenkins agent for node {instance_name}";

# Install Datadog agent
Install-DatadogAgent -DatadogAPIKey "{datadog_api_key}";

# Rename de computer and restart
Rename-Computer -NewName "{instance_name}" -Restart -Force;
'@

# Create script file
New-Item -ItemType File -Name "initializeInstance.ps1" -Path "$env:USERPROFILE\Documents";
Set-Content -Path "$env:USERPROFILE\Documents\initializeInstance.ps1" -Value $scriptContent;

# Create scheduled task to execute the script
$actions = New-ScheduledTaskAction –Execute "powershell.exe" -Argument "-File $env:USERPROFILE\Documents\initializeInstance.ps1";
$task = New-ScheduledTask -Action $actions;
Register-ScheduledTask 'initializeInstance' -User "opc" -Password '{instance_password}' -InputObject $task;

Start-ScheduledTask -TaskName 'initializeInstance';
Stop-Transcript;
"""

    # Execute a PowerShell commands
    result = session.run_ps(script)
    return response.Response(
        ctx, response_data=json.dumps(
            {
                "message": result.std_out.decode('utf-8')
            }
        ),
        headers={"Content-Type": "application/json"}
    )