import telepot

userName = 486322403
TOKEN = '621997304:AAHpriZ51VcJCxlg7wGQbiadvtb-OZ5vPu8'
bot = telepot.Bot(TOKEN)

if TEXT:
    bot.sendMessage(userName, txtMsg)
else:
    bot.sendDocument(userName, open(filePath, 'rb'))