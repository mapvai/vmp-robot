from nyt_news import NYTNews

news = NYTNews("2023-04-24", "Example Title","Example 11 dollars description.","https://example.com/picture.jpg")
news.setPictureName('Te va')
print(news.containsMoney())
print(news.getCountSearchPhrases('Title'))

