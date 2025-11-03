AI Daily Email Report (RAG Pipeline)

This project is a complete 4-phase RAG (Retrieval-Augmented Generation) pipeline that automatically reads your daily Gmail emails, processes them, and generates a concise daily briefing.

The final report is emailed to you every morning, so you never miss an important deadline, action item, or update.

Features

The daily report is a clean Markdown file with five key sections:

Job Application Status: Tracks online assessments, rejections, and interview requests.

Banking Updates: Highlights important transactions, alerts, or statements.

LinkedIn Messages: Summarizes new direct messages or important connection requests.

Rent & Utilities: Finds any urgent bills, due dates, or payment reminders.

Other Action Items: A catch-all for any other tasks or requests found in your inbox.

Architecture (How It Works)

The project is a pipeline of Python scripts, designed to be run in order.

Phase 1: Ingestion (gmail_fetcher_v2.py)

Connects to the Gmail API and fetches all unread emails from the last 24 hours.

Stores these raw emails in a local SQLite database (my_emails.db).

Phase 2: Indexing (phase_2_indexing.py)

Scans the database for new, unprocessed emails.

Chunks each email into smaller, meaningful paragraphs.

Embeds each chunk by calling the Gemini API, converting text into "meaning vectors".

Stores these vectors in a local ChromaDB vector database (email_vector_db/).

Phase 3: Generation (phase_3_generation.py)

Defines the 5 questions for your report (Jobs, Bank, etc.).

For each question, it queries the vector database to find the most relevant email chunks.

It sends these chunks (as context) along with the question to the Gemini API.

Saves the AI-generated answers into a single Markdown file (daily_report_YYYY-MM-DD.md).

Phase 4: Delivery (phase_4_send_email.py)

Finds today's report file.

Uses the Gmail API to send the report as an email to your own address.

Setup Instructions

1. Prerequisites

Python 3.10+

A Google Account (for both Gmail and Google AI Studio)

2. Clone & Install Dependencies

Download or clone this project to your local machine.

Navigate to the project directory in your terminal:

cd /path/to/your/RAG_Email_Project


Create a Virtual Environment (Highly Recommended):

Using venv:

python3 -m venv venv
source venv/bin/activate


Using Conda (as in cron_job.sh):

conda create -n RAGProject python=3.10
conda activate RAGProject


Install all required libraries:

pip install -r requirements.txt


3. Configuration - Part A: Gmail API (For Reading/Sending Mail)

This step gives your scripts permission to access your Gmail inbox.

Go to the Google Cloud Console.

Create a New Project.

In the search bar, find and Enable the "Gmail API".

Go to "APIs & Services" > "OAuth consent screen":

Select External.

Fill in the required app name (e.g., "RAG Mail Sorter") and user support email (your email).

On the "Scopes" page, click "Add or Remove Scopes" and add the .../auth/gmail.modify scope.

On the "Test users" page, add your own email address.

Go to "Credentials" > "Create Credentials" > "OAuth client ID":

Set the Application type to Desktop app.

Click "Create".

A "Client created" box will appear. Click "Download JSON".

Rename the downloaded file to credentials.json and place it in your main project folder.

4. Configuration - Part B: Gemini API (For AI Reasoning)

This step gives your scripts permission to use the AI model.

Go to Google AI Studio.

Click "Create API key in new project".

Copy your new API key.

Open phase_2_indexing.py and phase_3_generation.py and paste this key into the GOOGLE_API_KEY variable at the top of both files.

5. First-Time Authentication (CRITICAL)

You must run Phase 1 once by hand to grant permission.

In your terminal (with your virtual environment activated), run:

python gmail_fetcher_v2.py


A browser window will open, asking you to log in to Google.

Log in and grant permission to your app (it will show the name you gave it in Step 3).

This will create a token.json file in your folder. This file is your permanent login key.

Your project is now fully set up.

How to Run

Manual Run

You can run the full pipeline at any time by running the scripts in order:

# 1. Get new emails (and refresh your token)
python gmail_fetcher_v2.py

# 2. Index the new emails
python phase_2_indexing.py

# 3. Generate the report from the index
python phase_3_generation.py

# 4. Email the new report to yourself
python phase_4_send_email.py


Automated Run (macOS with launchd)

This is the recommended way to run the project. We use launchd, Apple's modern scheduler, instead of cron.

1. Edit cron_job.sh (The Master Script):

This script runs the full pipeline and clears the database for a fresh daily run.

Open cron_job.sh.

Update PROJECT_DIR to your absolute path (e.g., /Users/amitmaheshwarvaranasi/Documents/projects/RAG Email Sorting).

Update PYTHON_EXE to the absolute path of the Python executable inside your virtual environment. Find it by running which python while your venv is active.

2. Edit com.ragreport.plist (The Scheduler):

This file tells launchd when to run your script.

Open com.ragreport.plist.

You must do a find-and-replace for the placeholder path:

Find: /Users/amitmaheshwarvaranasi/Documents/projects/RAG Email Sorting

Replace: Your actual absolute project path (this path appears 6 times in the file).

3. Load the Job:

Move the .plist file to the correct system folder:

mv com.ragreport.plist ~/Library/LaunchAgents/


Load the job into launchd:

launchctl load ~/Library/LaunchAgents/com.ragreport.plist


The job is now scheduled to run every night at 12:00 AM.

4. Test the Job:
You can trigger the job manually once to test it:

launchctl start com.ragreport


Wait about 30 seconds, then check your project folder. You should see two new log files:

rag_report.out.log (shows the script's progress)

rag_report.err.log (will contain any errors)

Project Files

gmail_fetcher_v2.py: (Phase 1) Fetches emails from Gmail.

phase_2_indexing.py: (Phase 2) Chunks emails and creates vector embeddings.

phase_3_generation.py: (Phase 3) Queries the vector DB and generates the report.

phase_4_send_email.py: (Phase 4) Emails the final report.

cron_job.sh: Master shell script that runs all 4 phases for automation.

com.ragreport.plist: launchd config file for scheduling on macOS.

requirements.txt: All Python dependencies.

README.md: This file.

credentials.json: (Generated) Your Google Cloud secret key.

token.json: (Generated) Your Gmail API authentication token.

my_emails.db: (Generated) SQLite database of your raw emails.

email_vector_db/: (Generated) ChromaDB vector database.

daily_report_...md: (Generated) The final report.