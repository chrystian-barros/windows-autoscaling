def create_node(
    jenkins_url, 
    jenkins_crumb, 
    node_name, 
    node_description, 
    node_num_executors, 
    node_remote_fs, 
    node_label, 
    username, 
    api_token
):
    import http.client
    import base64
    import urllib.parse
    import json

    # Start HTTP connection to Jenkins
    http_connection = http.client.HTTPSConnection(jenkins_url)

    # This JSON must have the node information
    node_details = {
        "name": f"{node_name}",
        "nodeDescription": f"{node_description}",
        "numExecutors": f"{node_num_executors}",
        "remoteFS": f"{node_remote_fs}",
        "labelString": f"{node_label}",
        "mode": "NORMAL",
        "": ["0", "0"],
        "launcher": {
            "stapler-class": "hudson.slaves.JNLPLauncher",
            "$class": "hudson.slaves.JNLPLauncher"
        },
        "retentionStrategy": {
            "stapler-class": "hudson.slaves.RetentionStrategy$Always",
            "$class": "hudson.slaves.RetentionStrategy$Always"
        },
        "nodeProperties": {
            "stapler-class-bag": "true"
        },
        "type": "hudson.slaves.DumbSlave",
        "Submit": "Save",
        "Jenkins-Crumb": f"{jenkins_crumb}"
    }

    # Convert the node details into enconded JSON
    json_string = json.dumps(node_details, separators=(',', ':'))
    json_encoded = urllib.parse.quote(json_string)

    # Process authentication details and enconde it
    auth_string = f"{username}:{api_token}"
    auth_encoded = base64.b64encode(auth_string.encode('utf-8')).decode('utf-8')

    # Final payload to be sent to Jenkins
    payload = (
        f"name={node_name}"
        f"&nodeDescription={node_description}"
        f"&_.numExecutors={node_num_executors}"
        f"&_.remoteFS={node_remote_fs}"
        f"&_.labelString={node_label}"
        f"&mode=NORMAL"
        f"&stapler-class=hudson.slaves.JNLPLauncher"
        f"&stapler-class=hudson.plugins.sshslaves.SSHLauncher"
        f"&stapler-class=hudson.slaves.RetentionStrategy%24Always"
        f"&stapler-class=hudson.slaves.SimpleScheduledRetentionStrategy"
        f"&stapler-class=hudson.slaves.RetentionStrategy%24Demand"
        f"&%24class=hudson.slaves.JNLPLauncher"
        f"&%24class=hudson.plugins.sshslaves.SSHLauncher"
        f"&%24class=hudson.slaves.RetentionStrategy%24Always"
        f"&%24class=hudson.slaves.SimpleScheduledRetentionStrategy"
        f"&%24class=hudson.slaves.RetentionStrategy%24Demand"
        f"&stapler-class-bag=true"
        f"&_.freeDiskSpaceThreshold=1GiB"
        f"&_.freeDiskSpaceWarningThreshold=2GiB"
        f"&_.freeTempSpaceThreshold=1GiB"
        f"&_.freeTempSpaceWarningThreshold=2GiB"
        f"&type=hudson.slaves.DumbSlave"
        f"&Submit=Save"
        f"&Jenkins-Crumb={jenkins_crumb}"
        f"&json={json_encoded}"
    )

    # Set up the headers for the request
    headers = {
        'Content-Type': "application/x-www-form-urlencoded",
        'Jenkins-Crumb': f"{jenkins_crumb}",
        'User-Agent': "insomnia/12.5.0",
        'Authorization': f"Basic {auth_encoded}"
    }

    # Make the request to Jenkins API
    http_connection.request("POST", f"/computer/doCreateItem?name={node_name}", payload, headers)
    res = http_connection.getresponse()

    if res.status in [200, 201, 302]:
        response = json.dumps({
            "status": res.status,
            "message": f"Node {node_name} created successfully"
        })
        return response
    else:
        response = json.dumps({
            "status": res.status,
            "message": f"{res.read}"
        })
        raise Exception(f"Error creating node. Status code {res.status}: {res.read}.")

# print(create_node(
#     "dev-jenkins-puertorico.dtvlaweb.com:8443",
#     "ec3259ab0a0042a343b6c517a6933573c76f828464e0fbf10356fdc615f60e7a", 
#     "new-agent02", 
#     "teste de criacao de node", 
#     "2", 
#     "/var/jenkins",
#     "dev-puertorico_infrastructure",
#     "chrystian_barros",
#     "11d384147e41b49c902a255c3ccb57a311"
# ))