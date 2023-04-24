*** Settings ***
Documentation       Automate the process of extracting data from the news site NY Times.
...                 Open the site by following the link
...                 Enter a phrase in the search field
...                 On the result page, apply the following filters:
...                 -select a news category or section
...                 -choose the latest news
...                 Get the values: title, date, and description.
...                 -Store in an excel file:
...                 -title
...                 -date
...                 -description (if available)
...                 -picture filename
...                 -count of search phrases in the title and description
...                 -True or False, depending on whether the title or description contains any amount of money
...                 Possible formats: $11.1 | $111,111.11 | 11 dollars | 11 USD
...                 Download the news picture and specify the file name in the excel file
...                 Follow the steps 4-6 for all news that fall within the required time period

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.Excel.Files
Library             RPA.Desktop
Library             Collections
Library             re
Library             RPA.Tables
Library             String
Library             Process
Library             DateTime
Variables           ../Locators/nyt_locators.py
Variables           ../Configuration/nyt_extract_data.yaml


*** Variables ***
@{news_columns}
...                 Date
...                 Title
...                 Description
...                 Picture Name
...                 Count of search phrases
...                 Contains any amount of money

${regex_money}      (\\$[\\d]+(\\,\\d{3})(\\.\\d+)?)|(\\$[\\d]+(\\.\\d)?)|([\\d]+ dollars)|([\\d]+ USD)


*** Tasks ***
Extract latest news from NY Times and save them in a Excel file
    ${startDate}=    Get Start Date Formatted
    ${endDate}=    Get End Date Formatted
    Open The NY Times site    ${query}    ${startDate}    ${endDate}
    Select section
    Sleep    2
    Load all available news
    Sleep    2
    ${all_news_list}=    Scrap all news
    Save images and store name    ${all_news_list}
    Analize news data and store results    ${all_news_list}
    Export all news as a Excel    ${all_news_list}


*** Keywords ***
Get Start Date Formatted
    ${currentDate}=    Get Current Date
    ${number_of_months}=    Evaluate    1 if ${number_of_months} == 0 else ${number_of_months}
    ${number_of_days}=    Evaluate    ${number_of_months}*30
    ${startDate}=    Subtract Time From Date    ${currentDate}    ${number_of_days} days    result_format=%Y%m%d
    RETURN    ${startDate}

Get End Date Formatted
    ${endDate}=    Get Current Date    result_format=%Y%m%d
    RETURN    ${endDate}

Code tests
    Get Start Date Formatted
    Get End Date Formatted

Open The NY Times site
    [Arguments]    ${query}    ${startDate}    ${endDate}
    ${url}=    Format String    ${url}    query=${query}    startDate=${startDate}    endDate=${endDate}
    Open Available Browser    ${url}    #${browser}
    #Maximize Browser Window

Select section
    ${SectionCheckboxXpath}=    Format String    ${SectionCheckbox}    section=${section}
    Click Button    ${SectionSelector}
    Click Element    ${SectionCheckboxXpath}
    Click Button    ${SectionSelector}

Load all available news
    ${element_present}=    Run Keyword And Return Status    Element Should Be Visible    ${showMoreButton}
    WHILE    ${element_present}
        Run Keyword And Ignore Error    Click Element    ${showMoreButton}
        Sleep    0.2
        ${element_present}=    Run Keyword And Return Status    Element Should Be Visible    ${showMoreButton}
    END

Scrap all news
    ${all_news_list}=    Create List
    ${news_counter}=    Get Element Count
    ...    ${allNewsResults}
    FOR    ${i}    IN RANGE    1    ${news_counter}+1
        ${DateRelativeLocatorXpath}=    Format String    ${DateRelativeLocator}    i=${i}
        ${date}=    Get Text or Get Text    ${DateRelativeLocatorXpath}
        ${TitleRelativeLocatorXpath}=    Format String    ${TitleRelativeLocator}    i=${i}
        ${title}=    Get Text or Get Text    ${TitleRelativeLocatorXpath}
        ${DescriptionRelativeLocatorXpath}=    Format String    ${DescriptionRelativeLocator}    i=${i}
        TRY
            ${description}=    RPA.Browser.Selenium.Get Text
            ...    ${DescriptionRelativeLocatorXpath}
        EXCEPT    message
            ${description}='Desscription not found'
            CONTINUE
        END
        ${ImageRelativeLocatorXpath}=    Format String    ${ImageRelativeLocator}    i=${i}
        ${picture_url}=    Get Element Attribute or Get Element Attribute
        ...    ${ImageRelativeLocatorXpath}
        ...    src
        ${news}=    Create List    ${date}    ${title}    ${description}    ${picture_url}
        Append To List    ${all_news_list}    ${news}
    END
    RETURN    ${all_news_list}

Save images and store name
    [Arguments]    ${news_list}
    FOR    ${news}    IN    @{news_list}
        ${image_url}=    Get From List    ${news}    3
        ${image_name}=    Get Image Name
        Set List Value    ${news}    3    ${image_name}
        ${image_path}=    Set Variable    ${OUTPUT_DIR}${/}${image_folder}${/}${image_name}
        Run Process    curl    -o    ${image_path}    ${image_url}
    END

Get Image Name
    ${image_name}=    Get Current Date
    ${image_name}=    Convert Date    ${image_name}    epoch
    ${image_name}=    Evaluate    ${image_name}*${1000}
    ${image_name}=    Convert To Integer    ${image_name}
    ${image_name}=    Convert To String    ${image_name}
    ${image_name}=    Set Variable    ${image_name}.jpg
    RETURN    ${image_name}

Analize news data and store results
    [Arguments]    ${news_list}
    FOR    ${news}    IN    @{news_list}
        ${title}=    Get From List    ${news}    1
        ${description}=    Get From List    ${news}    2
        ${titDescUpper}=    Convert To Upper Case    ${title} ${description}
        ${phraseUpper}=    Convert To Upper Case    ${query}
        ${count}=    Count Occurrences whole phrase    ${titDescUpper}    ${phraseUpper}
        ${match_found}=    Check contains any amount of money    ${titDescUpper}
        Append To List    ${news}    ${count}    ${match_found}
    END

Check contains any amount of money
    [Arguments]    ${string}
    ${pure_string}=    Remove String    ${string}    '    ’    `
    ${matches}=    Get Regexp Matches    ${pure_string}    ${regex_money}
    ${match_found}=    Evaluate    len(${matches}) > 0
    ${match_found}=    Evaluate    "True" if ${match_found} != 0 else "False"
    RETURN    ${match_found}

Count Occurrences word by word
    [Arguments]    ${string}    ${phrase}
    ${search_tokens}=    Split String    ${phrase}
    ${pure_string}=    Remove String    ${string}    '
    ${count}=    Evaluate    sum([ '${pure_string}'.count(token) for token in ${search_tokens} ])
    RETURN    ${count}

Count Occurrences whole phrase
    [Arguments]    ${string}    ${phrase}
    ${pure_string}=    Remove String    ${string}    '
    ${count}=    Evaluate    '${pure_string}'.count('${phrase}')
    RETURN    ${count}

Export all news as a Excel
    [Arguments]    ${news_list}
    Insert Into List    ${news_list}    0    ${news_columns}
    ${startDate}=    Get Start Date Formatted
    Create Workbook
    ...    path=${OUTPUT_DIR}${/}${startDate}${excel_file}
    ...    sheet_name=${sheet_name}
    Set Active Worksheet    ${sheet_name}
    Append Rows To Worksheet
    ...    content=${news_list}
    ...    header=${False}
    ...    start=1
    Save Workbook

Run Until Keyword Success
    [Arguments]    ${KW}    @{KWARGS}
    Wait Until Keyword Succeeds    10s    1s    ${KW}    @{KWARGS}

Get text and place it in Arg
    [Arguments]    ${xpath}    ${wrapped}
    ${text}=    RPA.Browser.Selenium.Get Text    ${xpath}
    Append To List    ${wrapped}    ${text}

Get Text or Get Text
    [Arguments]    ${xpath}
    ${wrapped}=    Create List
    Run Until Keyword Success    Get text and place it in Arg    ${xpath}    ${wrapped}
    ${text}=    Get From List    ${wrapped}    0
    RETURN    ${text}

Get Element Attribute and place it in Arg
    [Arguments]    ${xpath}    ${wrapped}    ${atr}
    ${text}=    RPA.Browser.Selenium.Get Element Attribute    ${xpath}    ${atr}
    Append To List    ${wrapped}    ${text}

Get Element Attribute or Get Element Attribute
    [Arguments]    ${xpath}    ${atr}
    ${wrapped}=    Create List
    Run Until Keyword Success    Get Element Attribute and place it in Arg    ${xpath}    ${wrapped}    ${atr}
    ${text}=    Get From List    ${wrapped}    0
    RETURN    ${text}
