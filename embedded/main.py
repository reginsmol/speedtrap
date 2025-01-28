import asyncio
import aiohttp
import os
from dotenv import load_dotenv
load_dotenv()

token = os.getenv("CLOUDFLARE_IMAGES_TOKEN")

def create_cloudflare_session():
    headers = {
        'Authorization': f"Bearer {token}"
    }
    return aiohttp.ClientSession(connector=aiohttp.TCPConnector(ssl=False), headers=headers)

async def upload_image(cfSession): 
    async with cfSession as session:
        url ='https://api.cloudflare.com/client/v4/accounts/bc1348675f0636ae3eadada324c3a9c6/images/v1'
        files = {'file': open('./images/plate.jpg', 'rb')}

        async with await session.post(url, data=files) as resp:
            print(resp.status)
            data = await resp.json()
            return data["result"]["id"]

async def create_capture(cfSession):
    fileId = await upload_image(cfSession=cfSession)
    
    async with aiohttp.ClientSession() as session:
        body = {
            'fileId': fileId,
            'speed': 45
        }
        
        async with session.post('http://localhost:8080/api/captures', data=body) as response:
            print("Status:", response.status)
            print("Content-type:", response.headers['content-type'])

            html = await response.json()
            print("Body:", html)

async def main():
    input("Press any key")
    session = create_cloudflare_session()
    await create_capture(cfSession=session)
    await main()

asyncio.run(main())