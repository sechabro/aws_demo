import asyncio
import json
import os

import boto3
import httpx


async def ipabuse_check(ip: str, ipdb_key: str):
    url = "https://api.abuseipdb.com/api/v2/check"
    headers = {
        "Key": ipdb_key,
        "Accept": "application/json"
    }
    params = {
        "ipAddress": ip,
        "maxAgeInDays": 90
    }

    async with httpx.AsyncClient() as client:
        response = await client.get(url, headers=headers, params=params)
        response.raise_for_status()  # raises an error for bad responses

    return response.json().get("data", {})

async def async_handler(event, context):
    # get IP from event (API GW v2 HTTP example)
    ip = (
        event.get("queryStringParameters", {}) or {}
    ).get("ip") or event.get("ip")
    if not ip:
        return {"statusCode": 400, "body": json.dumps({"error": "missing 'ip'"})}

    ssm = boto3.client("ssm")
    param_name = os.environ["IPDB"]
    resp = ssm.get_parameter(Name=param_name, WithDecryption=True)
    ipdb_key = resp["Parameter"]["Value"]
    data = await ipabuse_check(ip, ipdb_key)
    return {"statusCode": 200, "body": json.dumps(data)}

def main(event, context):
    return asyncio.run(async_handler(event, context))