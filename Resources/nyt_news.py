import re
from robot.api.deco import keyword

@keyword
class NYTNews:
    __version__ = '0.1'
    
    def __init__(self, date, title, description, picture_url):
        self.date = date
        self.title = title
        self.description = description
        self.picture_url = picture_url
        self.picture_name = ''
    
    @keyword
    def setPictureName(self, picture_name):
        self.picture_name = picture_name
    
    @keyword
    def getCountSearchPhrases(self, phrase):
        text = self.title + self.description
        text = text.replace('\'', '')
        count = text.count(phrase)
        #search_tokens = text.split
        #count = sum([text.count(token) for token in search_tokens])
        return  count
    
    def containsMoney(self):
        text = self.title + self.description
        text = text.replace('\'', '')
        regex_money = re.compile('(\\$[\\d]+(\\,\\d{3})(\\.\\d+)?)|(\\$[\\d]+(\\.\\d)?)|([\\d]+ dollars)|([\\d]+ USD)')
        print(regex_money)
        match = regex_money.match(text)
        return True if match else False


