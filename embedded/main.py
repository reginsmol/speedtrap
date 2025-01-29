import asyncio
import aiohttp
import os
import time
# from dotenv import load_dotenv

# load_dotenv()

token = os.getenv("CLOUDFLARE_IMAGES_TOKEN")
from picamera2 import Picamera2

picam2 = Picamera2()
picam2.start()

def create_cloudflare_session():
    headers = {
        'Authorization': f"Bearer {token}"
    }
    return aiohttp.ClientSession(connector=aiohttp.TCPConnector(ssl=False), headers=headers)

def capture_image():
    filename = f"./images/{time.time()}.jpg"
    picam2.capture_file(filename)    
    return filename

async def upload_image(cfSession, filename):
    async with cfSession as session:
        url ='https://api.cloudflare.com/client/v4/accounts/bc1348675f0636ae3eadada324c3a9c6/images/v1'
        files = {'file': open(filename, 'rb')}

        async with await session.post(url, data=files) as resp:
            print(resp.status)
            data = await resp.json()
            return data["result"]["id"]

async def create_capture(cfSession):
    filename = capture_image()
    fileId = await upload_image(cfSession=cfSession, filename=filename)
    
    baseUrl = os.getenv("SPEEDTRAP_API_HOST")
    
    async with aiohttp.ClientSession(base_url=baseUrl, connector=aiohttp.TCPConnector(ssl=False)) as session:
        body = {
            'fileId': fileId,
            'speed': 45
        }
        
        token = os.getenv("SPEEDTRAP_API_TOKEN")
        
        session.headers.add("Authorization", f"Bearer {token}")

        async with session.post('/api/captures', data=body) as response:
            print("Status:", response.status)
            print("Content-type:", response.headers['content-type'])

            body = await response.json()
            print("Body:", body)

async def main():
    input("Press any key")
    session = create_cloudflare_session()
    await create_capture(cfSession=session)
    await main()

asyncio.run(main())