def get_jenkins_crumb(jenkins_url, username, api_token):
    import http.client
    import base64
    import json

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

    # Get Jenkins Crumb
    http_connection.request("GET", "/crumbIssuer/api/json", headers=headers)
    res = http_connection.getresponse()
    data = res.read()

    if res.status in [200, 201, 302]:
        crumb_data = json.loads(data.decode('utf-8'))
        response = json.dumps({
            "status": res.status,
            "crumb": f"{crumb_data.get('crumb')}"
        })
        return response
    else:
        response = json.dumps({
            "status": res.status,
            "message": f"{res.read}"
        })
        raise Exception(f"Error retriving Jenkins Crumb. Status code {res.status}: {data.decode('utf-8')}.")