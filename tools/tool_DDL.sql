-- Create_HTML Tool Description:

-- PROCEDURE/FUNCTION DETAILS:
-- Type: Stored Procedure
-- Language: Python 3.9
-- Signature: CREATE_HTML_NEWSLETTER_SP(subject STRING, body_markdown STRING)
-- Returns: STRING (specifically, a full HTML document)
-- Execution: OWNER's Rights
-- Volatility: IMMUTABLE
-- Primary Function: Converts Markdown text into a responsive, professionally styled HTML email.
-- Dependencies: Requires the markdown Python package.

-- Error Handling: The procedure relies on the underlying markdown library for parsing. Invalid Markdown may result in unformatted or broken HTML output, but the procedure itself does not have custom error handling for malformed input.

-- DESCRIPTION:
-- This Python-based stored procedure functions as a content formatting tool, specifically designed to transform simple Markdown text into a polished, responsive HTML email or newsletter. It accepts a subject line and a body of content written in Markdown, then wraps this content in a pre-defined, aesthetically pleasing HTML template.

-- The key advantage of this tool is that it offloads the complexity of HTML email creation. An AI agent can focus on synthesizing data and generating high-quality content in the simple and intuitive Markdown syntax, while this procedure handles the nuances of email client compatibility, inline CSS, and responsive table-based layouts. The output is a single, self-contained HTML string ready to be sent by an email delivery service. The template includes Snowflake-branded colors, a clear header, a call-to-action button placeholder, and a standardized footer.

-- USAGE SCENARIOS:
-- AI Agent Orchestration: Serves as the final formatting step for an AI agent. The agent can query data, perform analysis, summarize its findings in Markdown, and then call this procedure to produce a human-readable email report for distribution.

-- Automated Reporting: Can be integrated into automated workflows or tasks to convert scheduled query results into daily, weekly, or monthly email reports. For example, summarizing sales data and sending it to stakeholders.

-- Internal Communications: Enables the programmatic creation of internal newsletters, company announcements, or team updates based on information stored within Snowflake.

-- Personalized Notifications: Generate dynamic, well-formatted transactional emails or alerts for users, where the content is generated based on database triggers or events.



CREATE OR REPLACE PROCEDURE "CREATE_HTML_NEWSLETTER_SP"("SUBJECT" VARCHAR, "BODY_MARKDOWN" VARCHAR)
RETURNS VARCHAR
LANGUAGE PYTHON
RUNTIME_VERSION = '3.9'
PACKAGES = ('snowflake-snowpark-python','markdown')
HANDLER = 'main'
EXECUTE AS OWNER
AS '
import markdown

def main(session, subject: str, body_markdown: str) -> str:
    """
    Converts a subject and markdown text into a responsive, well-formatted HTML email.

    Args:
        session: The Snowflake session object.
        subject: The subject line of the email, also used as the main title.
        body_markdown: The content of the email in Markdown format.

    Returns:
        A string containing the full HTML for the email.
    """
    # --- 1. Convert the main body from Markdown to HTML ---
    # The ''tables'' extension allows for the conversion of Markdown tables.
    html_content = markdown.markdown(body_markdown, extensions=[''tables''])

    # --- 2. Define Inline CSS Styles for Email Client Compatibility ---
    # Using inline styles is a best practice for HTML emails as many clients
    # strip <style> tags and external stylesheets.
    styles = {
        "body": "font-family: -apple-system, BlinkMacSystemFont, ''Segoe UI'', Roboto, Helvetica, Arial, sans-serif, ''Apple Color Emoji'', ''Segoe UI Emoji'', ''Segoe UI Symbol''; background-color: #f4f7f6; margin: 0; padding: 0;",
        "wrapper": "width: 100%; table-layout: fixed; -webkit-text-size-adjust: 100%; -ms-text-size-adjust: 100%;",
        "outer_table": "margin: 0 auto; width: 100%; max-width: 600px; border-spacing: 0; font-family: sans-serif; color: #333333;",
        "main_content": "background-color: #ffffff; padding: 20px 40px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);",
        "header": "font-size: 28px; font-weight: bold; color: #0d172b; padding-bottom: 20px; text-align: center; border-bottom: 1px solid #e0e0e0;",
        "content_body": "font-size: 16px; line-height: 1.6; color: #3d4c5c; padding-top: 20px;",
        "footer": "text-align: center; padding: 20px; font-size: 12px; color: #888888;",
        "button": "background-color: #29b5e8; color: #ffffff; padding: 12px 25px; border-radius: 5px; text-decoration: none; display: inline-block; font-weight: bold;",
        "table": "width: 100%; border-collapse: collapse; margin-top: 15px; margin-bottom: 15px;",
        "th": "border: 1px solid #dddddd; text-align: left; padding: 8px; background-color: #f2f2f2;",
        "td": "border: 1px solid #dddddd; text-align: left; padding: 8px;"
    }

    # --- 3. Construct the Full HTML Document using an f-string ---
    # The structure uses tables for layout to ensure maximum compatibility with older email clients like Outlook.
    html_template = f"""
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
  <meta http-equiv="X-UA-Compatible" content="IE=edge" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{subject}</title>
  <style type="text/css">
      /* Basic styles for HTML elements converted from markdown */
      table {{ {styles[''table'']} }}
      th {{ {styles[''th'']} }}
      td {{ {styles[''td'']} }}
      h1, h2, h3 {{ color: #0d172b; }}
      p {{ margin: 0 0 1em 0; }}
      a {{ color: #29b5e8; text-decoration: underline; }}
      ul, ol {{ padding-left: 20px; margin-bottom: 1em; }}
      li {{ margin-bottom: 0.5em; }}
  </style>
</head>
<body style="{styles[''body'']}">
  <center class="wrapper" style="{styles[''wrapper'']}">
    <table class="outer" align="center" style="{styles[''outer_table'']}">
      <tr>
        <td style="padding: 20px;">
          <table width="100%" style="border-spacing: 0;">
            <tr>
              <td style="{styles[''main_content'']}">
                <div class="header" style="{styles[''header'']}">
                  {subject}
                </div>
                <div class="content-body" style="{styles[''content_body'']}">
                  {html_content}
                  <p style="text-align:center; padding-top: 25px;">
                      <a href="#" style="{styles[''button'']}">Call to Action</a>
                  </p>
                </div>
              </td>
            </tr>
          </table>
        </td>
      </tr>
      <tr>
        <td class="footer" style="{styles[''footer'']}">
          Snowflake Inc. &copy; 2025<br>
          125 Constitution Dr, Menlo Park, CA 94025<br>
          <a href="#" style="color: #888888;">Unsubscribe</a>
        </td>
      </tr>
    </table>
  </center>
</body>
</html>
"""
    return html_template
';






-- Email_Send Tool Description:

-- This tool calls a stored procedure that sends an email with the parameters subject_line and body_content. 

-- IMPORTANT: Do not use this tool until you have already shown the user a draft of the email and they have confirmed you can send it. 
-- Calling the tool sends the email, so do not call it without permission.

CREATE OR REPLACE PROCEDURE "SEND_CUSTOM_EMAIL"("SUBJECT_LINE" VARCHAR, "BODY_CONTENT" VARCHAR)
RETURNS BOOLEAN
LANGUAGE SQL
EXECUTE AS OWNER
AS '
BEGIN
    CALL SYSTEM$SEND_EMAIL(
        ''my_email_int'', -- Your integration name here
        ''<your_email_here>'',
        :subject_line,
        :body_content,
        ''text/html''
    );
END;
';





-- WEB_SEARCH Tool Description:

-- PROCEDURE/FUNCTION DETAILS:
-- Type: User-Defined Function
-- Language: Python 3.10
-- Signature: Web_search(query STRING)
-- Returns: STRING (specifically, a JSON-formatted string)
-- Execution: OWNER with CALLED ON NULL INPUT
-- Volatility: VOLATILE
-- Primary Function: Web search, result extraction, and structured output generation
-- Target: External search engine (DuckDuckGo HTML endpoint) via HTTP requests

-- Error Handling: Returns a JSON object with an "error" key upon request or parsing failure. Returns a JSON object with a "status" key when no results are found.

-- DESCRIPTION:
-- This Python-based function acts as a web search tool, designed to find and return a structured list of search results for a given query. It performs an HTTP request to a specialized HTML endpoint of the DuckDuckGo search engine. The function automatically filters out sponsored advertisements and extracts the title, URL, and content snippet from the top three organic search results. The output is a machine-readable JSON string, making it an ideal first-step tool for an AI agent or any automated workflow.

-- The function is marked as VOLATILE because its results depend on external, unpredictable data. It requires external network access through the Snowflake_intelligence_ExternalAccess_Integration, and users should be mindful of permissions and adherence to search engine policies.

-- USAGE SCENARIOS:
-- AI Agent Orchestration: Serves as the initial tool for an AI agent to find relevant URLs for a query. The agent can then parse the JSON output, extract the links, and use a subsequent tool like Web_scrape to retrieve the full content of those pages.
-- Automated Research: Programmatically identifying and collecting information on specific topics or keywords, providing a list of top-ranked sources without manual Browse.
-- Content Discovery: Finding new articles, blogs, or websites related to a topic for content curation or monitoring.
-- Link Analysis: Gathering a set of external links to analyze for authority, relevance, or other metrics.


CREATE OR REPLACE FUNCTION "WEB_SEARCH"("QUERY" VARCHAR)
RETURNS VARCHAR
LANGUAGE PYTHON
RUNTIME_VERSION = '3.10'
PACKAGES = ('requests','beautifulsoup4')
HANDLER = 'search_web'
EXTERNAL_ACCESS_INTEGRATIONS = (SNOWFLAKE_INTELLIGENCE_EXTERNALACCESS_INTEGRATION)
AS '
import _snowflake
import requests
from bs4 import BeautifulSoup
import urllib.parse
import json

def search_web(query):
    encoded_query = urllib.parse.quote_plus(query)
    search_url = f"https://html.duckduckgo.com/html/?q={encoded_query}"
    
    headers = {
        ''User-Agent'': ''Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36''
    }

    try:
        response = requests.get(search_url, headers=headers, timeout=10)
        response.raise_for_status() 
        
        soup = BeautifulSoup(response.text, ''html.parser'')
        
        search_results_list = []
        
        results_container = soup.find(id=''links'')

        if results_container:
            for result in results_container.find_all(''div'', class_=''result''):
                # Check if the result is an ad and skip it.
                if ''result--ad'' in result.get(''class'', []):
                    continue

                # Find title, link, and snippet.
                title_tag = result.find(''a'', class_=''result__a'')
                link_tag = result.find(''a'', class_=''result__url'')
                snippet_tag = result.find(''a'', class_=''result__snippet'')
                
                if title_tag and link_tag and snippet_tag:
                    title = title_tag.get_text(strip=True)
                    link = link_tag[''href'']
                    snippet = snippet_tag.get_text(strip=True)
                    
                    # Append the result as a dictionary to our list.
                    search_results_list.append({
                        "title": title,
                        "link": link,
                        "snippet": snippet
                    })

                # Break the loop once we have the top 3 results.
                if len(search_results_list) >= 3:
                    break

        if search_results_list:
            # Return the list of dictionaries as a JSON string.
            return json.dumps(search_results_list, indent=2)
        else:
            # Return a JSON string indicating no results found.
            return json.dumps({"status": "No search results found."})

    except requests.exceptions.RequestException as e:
        return json.dumps({"error": f"An error occurred while making the request: {e}"})
    except Exception as e:
        return json.dumps({"error": f"An unexpected error occurred during parsing: {e}"})
';




WEB_SCRAPE Tool instructions:

-- PROCEDURE/FUNCTION DETAILS:
-- - Type: User-Defined Function
-- - Language: Python 3.10
-- - Signature: Web_scrape(weburl STRING)
-- - Returns: STRING
-- - Execution: OWNER with CALLED ON NULL INPUT
-- - Volatility: VOLATILE
-- - Primary Function: Web scraping and content extraction
-- - Target: External web pages via HTTP requests
-- - Error Handling: Basic exception handling through requests library

-- DESCRIPTION:
-- This Python-based function enables users to fetch and extract text content from web pages by providing a URL as input. The function performs HTTP requests to retrieve web page content and uses BeautifulSoup to parse HTML and extract clean text, making it valuable for data collection, content analysis, and web scraping workflows within the database environment. Since it executes with OWNER privileges and requires external network access through the Snowflake_intelligence_ExternalAccess_Integration, users should ensure they have appropriate permissions and comply with website terms of service and rate limiting policies. The function is marked as VOLATILE because it accesses external resources that can change between calls, and it will execute even when passed NULL input values. Organizations should implement proper governance around its usage to prevent abuse and ensure compliance with data privacy regulations when scraping external websites.

-- USAGE SCENARIOS:
-- - Content monitoring and analysis: Regularly extracting text from news websites, blogs, or competitor pages for market intelligence and trend analysis
-- - Data enrichment workflows: Supplementing existing datasets with publicly available information from corporate websites, product pages, or regulatory filings
-- - Development and testing: Creating sample datasets for testing applications by extracting content from various web sources during development cycles



CREATE OR REPLACE FUNCTION "WEB_SCRAPE"("WEBURL" VARCHAR)
RETURNS VARCHAR
LANGUAGE PYTHON
RUNTIME_VERSION = '3.10'
PACKAGES = ('requests','beautifulsoup4')
HANDLER = 'get_page'
EXTERNAL_ACCESS_INTEGRATIONS = (SNOWFLAKE_INTELLIGENCE_EXTERNALACCESS_INTEGRATION)
AS '
import _snowflake
import requests
from bs4 import BeautifulSoup

def get_page(weburl):
  url = f"{weburl}"
  response = requests.get(url)
  soup = BeautifulSoup(response.text)
  return soup.get_text()
';