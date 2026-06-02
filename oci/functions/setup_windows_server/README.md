# setup_windows_server

OCI Fn Project function that automates the initial setup of a newly provisioned Windows Server instance. It is designed to be triggered by an OCI Event Rule when a new compute instance is created.

## How It Works

1. Receives an OCI Event payload containing the new instance metadata
2. Fetches secrets from OCI Vault (Windows password, Datadog API key, Jenkins API key)
3. Registers the instance as a new agent node in Jenkins
4. Resolves the instance's private IP via OCI VCN APIs
5. Connects to the instance over WinRM (NTLM, port 5985) and runs a PowerShell script that:
   - Sets the `PUERTORICO_APP` machine environment variable pointing to the NFS share
   - Installs MySQL CLI and OpenJDK via Chocolatey
   - Installs and configures the Windows NFS client and mounts the NFS share
   - Validates database connectivity
   - Installs the Datadog Agent
   - Renames the computer to match the OCI resource name and restarts

## Trigger — Event Payload

The function expects an OCI Events JSON body. The following fields are consumed:

| Field | Description |
|---|---|
| `data.resourceName` | Used as the new computer name and Jenkins node name |
| `data.resourceId` | OCI instance OCID, used to list VNIC attachments |
| `data.compartmentId` | Compartment OCID, used to list VNIC attachments |

Example (abbreviated):
```json
{
  "data": {
    "resourceName": "win-agent-01",
    "resourceId": "ocid1.instance.oc1...",
    "compartmentId": "ocid1.compartment.oc1..."
  }
}
```

## Environment Variables

All variables below must be configured in the Fn application or function configuration before deployment.

| Variable | Description |
|---|---|
| `SECRET_OCID` | OCID of the OCI Vault secret that holds the Windows `opc` user password (base64-encoded) |
| `DATADOG_API_KEY` | OCID of the OCI Vault secret that holds the Datadog API key (base64-encoded) |
| `JENKINS_API_KEY` | OCID of the OCI Vault secret that holds the Jenkins service account API token (base64-encoded) |
| `JENKINS_URL` | Jenkins hostname (e.g. `jenkins.example.com:8443`) — used for both the crumb request and node creation |
| `JENKINS_USERNAME` | Jenkins service account username |
| `MOUNT_TARGET_IP` | IP address of the OCI File Storage mount target |
| `EXPORT_PATH` | NFS export path (e.g. `/puertorico-app`) — forward slashes are stripped when building the UNC path |
| `DATABASE_HOSTNAME` | Hostname or IP of the database server, used to validate connectivity from the Windows instance |
| `DATABASE_PORT` | Port of the database server |

## OCI Permissions

The function uses Resource Principal authentication (`get_resource_principals_signer`). The dynamic group associated with the function must have the following IAM policies:

```
Allow dynamic-group <fn-dynamic-group> to read secret-bundles in compartment <compartment>
Allow dynamic-group <fn-dynamic-group> to read vnic-attachments in compartment <compartment>
Allow dynamic-group <fn-dynamic-group> to read vnics in compartment <compartment>
```

## Jenkins Node Configuration

The node is created as a `DumbSlave` with the following fixed values:

| Setting | Value |
|---|---|
| Number of executors | `2` |
| Remote FS root | `/var/jenkins` |
| Label | `dev-puertorico_infrastructure` |
| Launch method | JNLP |
| Retention strategy | Always |

## Response

On success, the function returns HTTP 200 with the PowerShell transcript output:

```json
{
  "message": "<stdout from the PowerShell script>"
}
```

Any failure during secret retrieval, Jenkins registration, VNIC resolution, or WinRM execution will raise an exception and return an error to the Fn runtime.

## Dependencies

Defined in `requirements.txt`:

| Package | Purpose |
|---|---|
| `fdk` | Fn Project Python development kit |
| `pywinrm` | WinRM client for connecting to the Windows instance |
| `oci` | OCI Python SDK for Vault, Compute, and VCN APIs |
