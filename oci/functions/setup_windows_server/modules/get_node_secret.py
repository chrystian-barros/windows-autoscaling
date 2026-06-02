def get_node_secret(jenkins_url, node_name, username, api_token):
    import http.client
    import base64
    import json
    import xmltodict

    # Process authentication details and enconde it
    auth_string = f"{username}:{api_token}"
    auth_encoded = base64.b64encode(auth_string.encode('utf-8')).decode('utf-8')

    # Start HTTP connection to Jenkins
    http_connection = http.client.HTTPSConnection(jenkins_url)

    # Set up the headers for the request
    headers = {
        'Authorization': f"Basic {auth_encoded}",
        'User-Agent': "insomnia/12.5.0"
    }

    # Get Jenkins node secret
    http_connection.request("GET", f"/computer/{node_name}/jenkins-agent.jnlp", headers=headers)
    res = http_connection.getresponse()
    data = res.read()

    if res.status == 200:
        xml_data = xmltodict.parse(data)
        json_data = json.dumps(xml_data['jnlp']['application-desc']['argument'][0])
        response = json.dumps({
            "status": res.status,
            "secret": f'''{json_data.replace('"', '')}'''
        })
        return response
    else:
        response = json.dumps({
            "status": res.status,
            "message": f"{res.read}"
        })
        raise Exception(f"Error retriving Jenkins Node Secret. Status code {res.status}: {data.decode('utf-8')}.")
