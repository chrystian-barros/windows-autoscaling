import io
import oci
import json
import os
import base64
import winrm
from fdk import response

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
# Paste your custom PowerShell script here. It will be executed right after the instance creation.
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