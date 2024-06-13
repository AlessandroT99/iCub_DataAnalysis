import telepot
import requests

userName = xxx
TOKEN = 'xxx'
bot = telepot.Bot(TOKEN)

if TEXT:
    bot.sendMessage(userName, txtMsg)
else:
    bot.sendDocument(userName, open(filePath, 'rb'))
