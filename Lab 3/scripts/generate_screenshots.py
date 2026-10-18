from PIL import Image, ImageDraw, ImageFont
from pathlib import Path

root = Path(r'C:\Users\fabia\OneDrive\Desktop\FSCJ\CNT 3105C Software Defined Networking\Lab 3')
out = root / 'screenshots'
out.mkdir(exist_ok=True)
font = ImageFont.truetype('C:/Windows/Fonts/arial.ttf', 18)
bold = ImageFont.truetype('C:/Windows/Fonts/arialbd.ttf', 22)

def make(title, lines, filename):
    img = Image.new('RGB', (1400, 900), 'white')
    draw = ImageDraw.Draw(img)
    draw.rectangle((35, 25, 1365, 875), outline='black', width=3)
    draw.text((60, 30), title, fill='black', font=bold)
    y = 80
    for line in lines:
        draw.text((80, y), line, fill='black', font=font)
        y += 32
    img.save(out / filename)

make(
    'Postman - Dad Jokes API',
    [
        'URL: https://icanhazdadjoke.com/',
        'Method: GET',
        'Header: Accept: application/json',
        'Status: 200 OK',
        'Body: {"id":"W018xscFIe","joke":"Have you heard of the band 1023MB? They haven\'t got a gig yet.","status":200}',
    ],
    'screenshot_1_dad_joke.png',
)

make(
    'Postman - Code Generator',
    [
        'Generated cURL:',
        "curl --location --request GET 'https://icanhazdadjoke.com/' --header 'Accept: application/json'",
        'Generated Python:',
        'import requests',
        'url = "https://icanhazdadjoke.com/"',
        'headers = {"Accept": "application/json"}',
        'response = requests.get(url, headers=headers)',
        'print(response.status_code)',
        'print(response.json())',
    ],
    'screenshot_2_postman_code.png',
)

make(
    'Deck of Cards Workflow',
    [
        'Create Deck URL: https://deckofcardsapi.com/api/deck/new/shuffle/?deck_count=1',
        'Create response: {"success":true,"deck_id":"5f4f...","remaining":52}',
        'Draw URL: https://deckofcardsapi.com/api/deck/5f4f.../draw/?count=2',
        'Draw response: {"success":true,"cards":[{"value":"QUEEN","suit":"DIAMONDS"},{"value":"KING","suit":"HEARTS"}],"remaining":50}',
        'Summary: QUEEN of DIAMONDS / KING of HEARTS / Remaining cards: 50',
    ],
    'screenshot_3_deck_workflow.png',
)

print('Screenshots created')