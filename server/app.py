import json

import requests
from flask import Flask, request, redirect

# Instagram client ID and secret from registering in dev portal
IG_CLIENT_ID = "5177a42c89db4a7d992f9ae52c143393"
# This should be kept secret in real life, but I am ok with this client getting shut down ;)
IG_CLIENT_SECRET = "adf4044a41a440b79823e09fc45b692b"

app = Flask(__name__)


@app.route('/callback')
def callback():
    # get code from request query param
    code = request.args["code"]
    # use code to perform oauth request to get auth token
    auth_resp = requests.post("https://api.instagram.com/oauth/access_token",
                              data={
                                  "client_id": IG_CLIENT_ID,
                                  "client_secret": IG_CLIENT_SECRET,
                                  "grant_type": "authorization_code",
                                  "code": code,
                                  "redirect_uri": request.base_url
                              })
    # assuming success we grab the access token (this does not handle errors properly!)
    token = json.loads(auth_resp.text)["access_token"]
    # redirect back to the app with the token as a query param
    redirect_url = "InstagramOauth://?token=" + str(token)
    print("Redirecting to " + redirect_url)
    return redirect(redirect_url)


if __name__ == '__main__':
    app.run(host="0.0.0.0")
