SectionSelector='xpath://div[@data-testid="section"]//button[@data-testid="search-multiselect-button"]'
SectionCheckbox='xpath://div[@data-testid="section"]//li[.//span[text()="{section}"]]//label//input[@type="checkbox"]'
ShowMoreButton='xpath://button[@data-testid="search-show-more-button"]'
AllNewsResults='xpath://ol[@data-testid="search-results"]//li[@data-testid="search-bodega-result"]'

# Relative locators
DateRelativeLocator=f'{AllNewsResults}['+'{i}]//div//span'
TitleRelativeLocator=f'{AllNewsResults}['+'{i}]//div//div//a//h4'
DescriptionRelativeLocator=f'{AllNewsResults}['+'{i}]//div//div//a//p[1]'
ImageRelativeLocator=f'{AllNewsResults}['+'{i}]//div//figure//div//img'